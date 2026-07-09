from datetime import date
from decimal import Decimal

from django.db import transaction
from django.db.models import F
from django.db.models import Sum
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import (
    CapitalContribution,
    Expense,
    FamilyWithdrawal,
    Inventory,
    Loan,
    LoanPayment,
    PersonalTransaction,
    Sale,
)
from .serializers import (
    CapitalContributionSerializer,
    ExpenseSerializer,
    FamilyWithdrawalSerializer,
    InventorySerializer,
    LoanPaymentSerializer,
    LoanSerializer,
    PersonalTransactionSerializer,
    SaleSerializer,
)


class UserOwnedModelViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class SaleViewSet(UserOwnedModelViewSet):
    serializer_class = SaleSerializer

    def get_queryset(self):
        queryset = Sale.objects.filter(user=self.request.user)
        sale_type = self.request.query_params.get("sale_type")
        if sale_type:
            queryset = queryset.filter(sale_type=sale_type)
        return queryset

    @action(detail=False, methods=["get"])
    def milk(self, request):
        serializer = self.get_serializer(self.get_queryset().filter(sale_type="milk"), many=True)
        return Response(serializer.data)

    @action(detail=False, methods=["get"])
    def cattle(self, request):
        serializer = self.get_serializer(self.get_queryset().filter(sale_type="cattle"), many=True)
        return Response(serializer.data)

    @action(detail=False, methods=["get"])
    def report(self, request):
        total = self.get_queryset().aggregate(total=Sum("total_amount"))["total"] or Decimal("0")
        by_type = (
            self.get_queryset().values("sale_type").annotate(total=Sum("total_amount")).order_by("sale_type")
        )
        return Response({"total_sales": total, "by_type": list(by_type)})


class ExpenseViewSet(UserOwnedModelViewSet):
    serializer_class = ExpenseSerializer

    def get_queryset(self):
        return Expense.objects.filter(user=self.request.user)

    @action(detail=False, methods=["get"])
    def category(self, request):
        by_category = self.get_queryset().values("category").annotate(total=Sum("amount")).order_by("category")
        return Response(list(by_category))

    @action(detail=False, methods=["get"])
    def report(self, request):
        total = self.get_queryset().aggregate(total=Sum("amount"))["total"] or Decimal("0")
        return Response({"total_expenses": total, "breakdown": self.category(request).data})


class FamilyWithdrawalViewSet(UserOwnedModelViewSet):
    serializer_class = FamilyWithdrawalSerializer

    def get_queryset(self):
        return FamilyWithdrawal.objects.filter(user=self.request.user)

    @transaction.atomic
    def perform_create(self, serializer):
        withdrawal = serializer.save(user=self.request.user)
        PersonalTransaction.objects.create(
            user=self.request.user,
            transaction_date=withdrawal.withdrawal_date,
            transaction_type="farm_transfer",
            category="farm_transfer",
            amount=withdrawal.amount,
            description=withdrawal.description or "Farm cash moved to personal pocket",
            source_withdrawal=withdrawal,
        )

    @transaction.atomic
    def perform_update(self, serializer):
        withdrawal = serializer.save(user=self.request.user)
        PersonalTransaction.objects.update_or_create(
            source_withdrawal=withdrawal,
            defaults={
                "user": self.request.user,
                "transaction_date": withdrawal.withdrawal_date,
                "transaction_type": "farm_transfer",
                "category": "farm_transfer",
                "amount": withdrawal.amount,
                "description": withdrawal.description or "Farm cash moved to personal pocket",
            },
        )

    @action(detail=False, methods=["get"])
    def total(self, request):
        total_amount = self.get_queryset().aggregate(total=Sum("amount"))["total"] or Decimal("0")
        return Response({"total_withdrawals": total_amount})


class PersonalTransactionViewSet(UserOwnedModelViewSet):
    serializer_class = PersonalTransactionSerializer

    def get_queryset(self):
        queryset = PersonalTransaction.objects.filter(user=self.request.user)
        transaction_type = self.request.query_params.get("transaction_type")
        if transaction_type:
            queryset = queryset.filter(transaction_type=transaction_type)
        return queryset

    @action(detail=False, methods=["get"])
    def summary(self, request):
        qs = self.get_queryset()
        income = qs.filter(transaction_type="income").aggregate(total=Sum("amount"))["total"] or Decimal("0")
        expenses = qs.filter(transaction_type="expense").aggregate(total=Sum("amount"))["total"] or Decimal("0")
        farm_transfers = qs.filter(transaction_type="farm_transfer").aggregate(total=Sum("amount"))["total"] or Decimal(
            "0"
        )
        by_category = (
            qs.filter(transaction_type="expense")
            .values("category")
            .annotate(total=Sum("amount"))
            .order_by("category")
        )
        return Response(
            {
                "personal_income": income,
                "personal_expenses": expenses,
                "farm_to_pocket": farm_transfers,
                "personal_balance": income + farm_transfers - expenses,
                "expense_by_category": list(by_category),
            }
        )


class CapitalContributionViewSet(UserOwnedModelViewSet):
    serializer_class = CapitalContributionSerializer

    def get_queryset(self):
        queryset = CapitalContribution.objects.filter(user=self.request.user)
        source_type = self.request.query_params.get("source_type")
        if source_type:
            queryset = queryset.filter(source_type=source_type)
        return queryset

    @action(detail=False, methods=["get"])
    def summary(self, request):
        qs = self.get_queryset()
        total = qs.aggregate(total=Sum("amount"))["total"] or Decimal("0")
        by_source = qs.values("source_type").annotate(total=Sum("amount")).order_by("source_type")
        return Response({"total_capital": total, "by_source": list(by_source)})


class LoanViewSet(UserOwnedModelViewSet):
    serializer_class = LoanSerializer

    def get_queryset(self):
        return Loan.objects.filter(user=self.request.user)

    @action(detail=True, methods=["post"])
    def payment(self, request, pk=None):
        loan = self.get_object()
        serializer = LoanPaymentSerializer(data={**request.data, "loan": loan.id})
        serializer.is_valid(raise_exception=True)
        payment = serializer.save()

        loan.paid_amount = (loan.paid_amount or Decimal("0")) + payment.total_payment
        loan.outstanding_amount = max(Decimal("0"), loan.loan_amount - loan.paid_amount)
        if loan.outstanding_amount == Decimal("0"):
            loan.status = "closed"
        loan.save(update_fields=["paid_amount", "outstanding_amount", "status", "updated_at"])

        return Response(LoanSerializer(loan).data, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=["get"])
    def summary(self, request):
        qs = self.get_queryset()
        total_loan = qs.aggregate(total=Sum("loan_amount"))["total"] or Decimal("0")
        total_outstanding = qs.aggregate(total=Sum("outstanding_amount"))["total"] or Decimal("0")
        total_paid = qs.aggregate(total=Sum("paid_amount"))["total"] or Decimal("0")
        return Response(
            {
                "total_loan": total_loan,
                "total_outstanding": total_outstanding,
                "total_paid": total_paid,
                "active_loans": qs.filter(status="active").count(),
            }
        )


class InventoryViewSet(UserOwnedModelViewSet):
    serializer_class = InventorySerializer

    def _apply_daily_usage(self):
        today = date.today()
        for item in Inventory.objects.filter(
            user=self.request.user,
            auto_deduct_enabled=True,
            daily_usage_quantity__gt=0,
        ):
            start_date = item.last_auto_deducted or item.last_updated or today
            days = (today - start_date).days
            if days <= 0:
                continue
            item.quantity = max(
                Decimal("0"),
                (item.quantity or Decimal("0")) - (item.daily_usage_quantity or Decimal("0")) * days,
            )
            item.last_auto_deducted = today
            item.last_updated = today
            item.save(update_fields=["quantity", "last_auto_deducted", "last_updated", "updated_at"])

    def get_queryset(self):
        return Inventory.objects.filter(user=self.request.user)

    def list(self, request, *args, **kwargs):
        self._apply_daily_usage()
        return super().list(request, *args, **kwargs)

    def retrieve(self, request, *args, **kwargs):
        self._apply_daily_usage()
        return super().retrieve(request, *args, **kwargs)

    @action(detail=True, methods=["post"], url_path="stock-in")
    def stock_in(self, request, pk=None):
        self._apply_daily_usage()
        item = self.get_object()
        amount = Decimal(str(request.data.get("quantity", "0")))
        item.quantity = (item.quantity or Decimal("0")) + amount
        item.last_updated = date.today()
        item.last_auto_deducted = date.today()
        item.save(update_fields=["quantity", "last_updated", "last_auto_deducted", "updated_at"])
        return Response(InventorySerializer(item).data)

    @action(detail=True, methods=["post"], url_path="stock-out")
    def stock_out(self, request, pk=None):
        self._apply_daily_usage()
        item = self.get_object()
        amount = Decimal(str(request.data.get("quantity", "0")))
        item.quantity = max(Decimal("0"), (item.quantity or Decimal("0")) - amount)
        item.last_updated = date.today()
        item.last_auto_deducted = date.today()
        item.save(update_fields=["quantity", "last_updated", "last_auto_deducted", "updated_at"])
        return Response(InventorySerializer(item).data)

    @action(detail=False, methods=["get"], url_path="low-stock")
    def low_stock(self, request):
        self._apply_daily_usage()
        queryset = self.get_queryset().filter(quantity__lte=F("reorder_level"))
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
