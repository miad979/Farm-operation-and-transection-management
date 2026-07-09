from datetime import timedelta
from decimal import Decimal

from django.db import models
from django.utils import timezone
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from animals.models import Animal
from financial.models import Inventory, Loan


def apply_daily_inventory_usage(user):
    today = timezone.localdate()
    for item in Inventory.objects.filter(
        user=user,
        auto_deduct_enabled=True,
        daily_usage_quantity__gt=0,
    ):
        start_date = item.last_auto_deducted or item.last_updated or today
        days = (today - start_date).days
        if days <= 0:
            continue

        item.quantity = max(
            Decimal("0"),
            (item.quantity or Decimal("0"))
            - (item.daily_usage_quantity or Decimal("0")) * days,
        )
        item.last_auto_deducted = today
        item.last_updated = today
        item.save(update_fields=["quantity", "last_auto_deducted", "last_updated", "updated_at"])


class NotificationsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = timezone.localdate()
        soon = today + timedelta(days=30)
        alerts = []
        apply_daily_inventory_usage(request.user)

        for animal in Animal.objects.filter(user=request.user, is_active=True).exclude(health_status="Healthy"):
            alerts.append(
                {
                    "type": "animal_health",
                    "title": f"{animal.name} needs attention",
                    "message": f"Health status: {animal.health_status}",
                    "due_date": today,
                }
            )

        for animal in Animal.objects.filter(user=request.user, is_active=True, vaccinated=False):
            alerts.append(
                {
                    "type": "vaccination_due",
                    "title": f"Vaccination not recorded for {animal.name}",
                    "message": "Add vaccination details when done.",
                    "due_date": today,
                }
            )

        for animal in Animal.objects.filter(
            user=request.user,
            is_active=True,
            expected_delivery_date__isnull=False,
            expected_delivery_date__lte=soon,
        ):
            alerts.append(
                {
                    "type": "pregnancy_checkup",
                    "title": f"Delivery/checkup near for {animal.name}",
                    "message": f"Expected date: {animal.expected_delivery_date}",
                    "due_date": animal.expected_delivery_date,
                }
            )

        for item in Inventory.objects.filter(user=request.user, quantity__lte=models.F("reorder_level")):
            alerts.append(
                {
                    "type": "low_stock",
                    "title": f"Low stock: {item.item_name}",
                    "message": f"{item.quantity} {item.unit} left.",
                    "due_date": today,
                }
            )

        for loan in Loan.objects.filter(user=request.user, status="active", repayment_start_date__lte=soon):
            alerts.append(
                {
                    "type": "loan_payment_due",
                    "title": f"Loan payment reminder: {loan.loan_source or 'Loan'}",
                    "message": f"Outstanding amount: {loan.outstanding_amount}",
                    "due_date": loan.repayment_start_date,
                }
            )

        return Response({"notifications": alerts, "unread_count": len(alerts)})
