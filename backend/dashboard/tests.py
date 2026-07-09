from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from animals.models import Animal
from financial.models import Inventory, Loan

User = get_user_model()


class DashboardApiTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="dashboard_user",
            email="dashboard@example.com",
            password="strongpass123",
        )
        self.client.force_authenticate(user=self.user)

    def test_today_summary_endpoint(self):
        response = self.client.get("/api/v1/dashboard/today/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("income", response.data)
        self.assertIn("expenses", response.data)
        self.assertIn("profit", response.data)

    def test_cash_flow_endpoint(self):
        response = self.client.get("/api/v1/dashboard/cash-flow/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("net_profit", response.data)
        self.assertIn("available_cash", response.data)

    def test_notifications_include_farm_warnings_and_auto_feed_use(self):
        today = timezone.localdate()
        Animal.objects.create(
            user=self.user,
            animal_id_number="ALERT-001",
            name="Lali",
            type="Cow",
            health_status="Sick",
            vaccinated=False,
            expected_delivery_date=today + timezone.timedelta(days=7),
        )
        feed = Inventory.objects.create(
            user=self.user,
            item_type="feed",
            item_name="Daily feed",
            quantity="12.00",
            unit="kg",
            reorder_level="5.00",
            daily_usage_quantity="4.00",
            auto_deduct_enabled=True,
            last_auto_deducted=today - timezone.timedelta(days=2),
        )
        Loan.objects.create(
            user=self.user,
            loan_amount="10000.00",
            loan_source="Bank",
            loan_date=today,
            repayment_start_date=today + timezone.timedelta(days=15),
            outstanding_amount="7000.00",
            status="active",
        )

        response = self.client.get("/api/v1/notifications/")
        feed.refresh_from_db()
        notification_types = {item["type"] for item in response.data["notifications"]}

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(str(feed.quantity), "4.00")
        self.assertIn("animal_health", notification_types)
        self.assertIn("vaccination_due", notification_types)
        self.assertIn("pregnancy_checkup", notification_types)
        self.assertIn("low_stock", notification_types)
        self.assertIn("loan_payment_due", notification_types)
        self.assertEqual(response.data["unread_count"], len(response.data["notifications"]))
