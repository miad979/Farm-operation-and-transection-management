from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from .models import Inventory

User = get_user_model()


class FinancialApiTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="finance_user",
            email="finance@example.com",
            password="strongpass123",
        )
        self.client.force_authenticate(user=self.user)

    def test_create_sale_and_report(self):
        sale_payload = {
            "sale_type": "milk",
            "sale_date": "2026-07-02",
            "customer_name": "Local Buyer",
            "quantity": "20.00",
            "unit": "liter",
            "price_per_unit": "60.00",
            "total_amount": "1200.00",
            "payment_method": "cash",
        }
        create_response = self.client.post("/api/v1/sales/", sale_payload, format="json")
        report_response = self.client.get("/api/v1/sales/report/")

        self.assertEqual(create_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(report_response.status_code, status.HTTP_200_OK)
        self.assertIn("total_sales", report_response.data)

    def test_loan_payment_flow(self):
        loan_payload = {
            "loan_amount": "50000.00",
            "loan_source": "Local Bank",
            "loan_date": "2026-07-01",
            "interest_rate": "10.00",
            "interest_type": "simple",
            "status": "active",
            "outstanding_amount": "50000.00",
        }
        loan_response = self.client.post("/api/v1/loans/", loan_payload, format="json")
        payment_payload = {
            "payment_date": "2026-07-02",
            "principal_amount": "5000.00",
            "interest_amount": "500.00",
            "payment_method": "cash",
        }
        pay_response = self.client.post(
            f"/api/v1/loans/{loan_response.data['id']}/payment/",
            payment_payload,
            format="json",
        )

        self.assertEqual(loan_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(pay_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(str(pay_response.data["paid_amount"]), "5500.00")

    def test_farm_withdrawal_adds_personal_pocket_money(self):
        withdrawal_payload = {
            "withdrawal_date": "2026-07-02",
            "amount": "3000.00",
            "reason": "household",
            "description": "Owner draw",
        }
        withdrawal_response = self.client.post(
            "/api/v1/withdrawals/",
            withdrawal_payload,
            format="json",
        )
        expense_response = self.client.post(
            "/api/v1/personal-transactions/",
            {
                "transaction_date": "2026-07-02",
                "transaction_type": "expense",
                "category": "food",
                "amount": "800.00",
                "description": "Family shopping",
            },
            format="json",
        )
        summary_response = self.client.get("/api/v1/personal-transactions/summary/")

        self.assertEqual(withdrawal_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(expense_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(str(summary_response.data["farm_to_pocket"]), "3000")
        self.assertEqual(str(summary_response.data["personal_expenses"]), "800")
        self.assertEqual(str(summary_response.data["personal_balance"]), "2200")

    def test_inventory_auto_deducts_daily_feed_use(self):
        item = Inventory.objects.create(
            user=self.user,
            item_type="feed",
            item_name="Cow feed",
            quantity="100.00",
            unit="kg",
            reorder_level="20.00",
            daily_usage_quantity="5.00",
            auto_deduct_enabled=True,
            last_auto_deducted=timezone.now().date() - timezone.timedelta(days=3),
        )

        response = self.client.get("/api/v1/inventory/")
        item.refresh_from_db()

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(str(item.quantity), "85.00")
