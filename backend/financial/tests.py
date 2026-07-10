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
            "paid_amount": "700.00",
            "payment_method": "cash",
        }
        create_response = self.client.post("/api/v1/sales/", sale_payload, format="json")
        report_response = self.client.get("/api/v1/sales/report/")
        dues_response = self.client.get("/api/v1/sales/dues/")

        self.assertEqual(create_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(report_response.status_code, status.HTTP_200_OK)
        self.assertEqual(dues_response.status_code, status.HTTP_200_OK)
        self.assertEqual(str(create_response.data["due_amount"]), "500.00")
        self.assertEqual(str(report_response.data["total_due"]), "500")
        self.assertEqual(str(dues_response.data[0]["due_amount"]), "500.00")
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
            last_auto_deducted=timezone.localdate() - timezone.timedelta(days=3),
        )

        response = self.client.get("/api/v1/inventory/")
        item.refresh_from_db()

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(str(item.quantity), "85.00")

    def test_frontend_core_workflow_payloads(self):
        today = timezone.localdate().isoformat()
        animal_response = self.client.post(
            "/api/v1/animals/",
            {
                "animal_id_number": "APP-001",
                "name": "Rani",
                "type": "Cow",
                "breed": "",
                "gender": "Female",
                "health_status": "Healthy",
            },
            format="json",
        )
        animal_id = animal_response.data["id"]
        update_animal_response = self.client.patch(
            f"/api/v1/animals/{animal_id}/",
            {
                "animal_id_number": "APP-001",
                "name": "Rani",
                "type": "Cow",
                "breed": "Local",
                "gender": "Female",
                "health_status": "Healthy",
                "vaccinated": True,
                "pregnancy_status": "Not Pregnant",
                "notes": "Good condition",
            },
            format="json",
        )
        milk_response = self.client.post(
            "/api/v1/milk-production/",
            {
                "animal": animal_id,
                "production_date": today,
                "morning_milk": "5.00",
                "evening_milk": "4.00",
                "quality_grade": "A",
            },
            format="json",
        )
        sale_response = self.client.post(
            "/api/v1/sales/",
            {
                "sale_type": "milk",
                "sale_date": today,
                "description": "Milk sale",
                "total_amount": "900.00",
                "payment_method": "cash",
            },
            format="json",
        )
        expense_response = self.client.post(
            "/api/v1/expenses/",
            {
                "category": "feed",
                "expense_date": today,
                "description": "Feed cost",
                "amount": "300.00",
                "payment_method": "cash",
            },
            format="json",
        )
        withdrawal_response = self.client.post(
            "/api/v1/withdrawals/",
            {
                "withdrawal_date": today,
                "reason": "household",
                "description": "Owner draw",
                "amount": "200.00",
            },
            format="json",
        )
        capital_response = self.client.post(
            "/api/v1/capital/",
            {
                "contribution_date": today,
                "source_type": "owner",
                "contributor_name": "Owner",
                "description": "Pocket investment",
                "amount": "1000.00",
                "payment_method": "cash",
            },
            format="json",
        )
        inventory_response = self.client.post(
            "/api/v1/inventory/",
            {
                "item_type": "feed",
                "item_name": "Ready feed",
                "quantity": "50.00",
                "unit": "kg",
                "reorder_level": "10.00",
                "daily_usage_quantity": "2.00",
                "auto_deduct_enabled": True,
                "last_updated": today,
                "last_auto_deducted": today,
            },
            format="json",
        )
        stock_out_response = self.client.post(
            f"/api/v1/inventory/{inventory_response.data['id']}/stock-out/",
            {"quantity": "5.00"},
            format="json",
        )
        loan_response = self.client.post(
            "/api/v1/loans/",
            {
                "loan_date": today,
                "loan_source": "Local Bank",
                "loan_amount": "5000.00",
                "outstanding_amount": "5000.00",
                "interest_rate": "5.00",
                "interest_type": "simple",
                "tenure_months": 6,
                "monthly_installment": "900.00",
                "repayment_start_date": today,
                "status": "active",
            },
            format="json",
        )
        payment_response = self.client.post(
            f"/api/v1/loans/{loan_response.data['id']}/payment/",
            {
                "payment_date": today,
                "principal_amount": "500.00",
                "interest_amount": "50.00",
                "payment_method": "cash",
            },
            format="json",
        )
        dashboard_response = self.client.get("/api/v1/dashboard/today/")
        personal_summary_response = self.client.get("/api/v1/personal-transactions/summary/")
        notifications_response = self.client.get("/api/v1/notifications/")

        for response in [
            animal_response,
            update_animal_response,
            milk_response,
            sale_response,
            expense_response,
            withdrawal_response,
            capital_response,
            inventory_response,
            stock_out_response,
            loan_response,
            payment_response,
            dashboard_response,
            personal_summary_response,
            notifications_response,
        ]:
            self.assertLess(response.status_code, 400, response.data)

        self.assertEqual(str(milk_response.data["total_milk"]), "9.00")
        self.assertEqual(str(stock_out_response.data["quantity"]), "45.00")
        self.assertEqual(str(personal_summary_response.data["farm_to_pocket"]), "200")
        self.assertIn("milk_production", dashboard_response.data)
        self.assertIn("notifications", notifications_response.data)
