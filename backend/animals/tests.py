from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase

User = get_user_model()


class AnimalsApiTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="animals_user",
            email="animals@example.com",
            password="strongpass123",
        )
        self.client.force_authenticate(user=self.user)

    def test_create_animal(self):
        payload = {
            "animal_id_number": "AN001",
            "name": "Lakshmi",
            "type": "Cow",
            "breed": "Holstein",
            "gender": "Female",
            "default_daily_milk": "8.50",
            "purchase_price": "45000.00",
            "current_value": "47000.00",
        }
        response = self.client.post("/api/v1/animals/", payload, format="json")

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["name"], "Lakshmi")
        self.assertEqual(str(response.data["default_daily_milk"]), "8.50")

    def test_create_milk_record(self):
        animal_response = self.client.post(
            "/api/v1/animals/",
            {
                "animal_id_number": "AN002",
                "name": "Radha",
                "type": "Cow",
            },
            format="json",
        )
        payload = {
            "animal": animal_response.data["id"],
            "production_date": "2026-07-02",
            "morning_milk": "6.50",
            "evening_milk": "5.50",
            "quality_grade": "A",
        }
        response = self.client.post("/api/v1/milk-production/", payload, format="json")

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(str(response.data["total_milk"]), "12.00")

    def test_default_daily_milk_counts_until_manual_record_overrides(self):
        animal_response = self.client.post(
            "/api/v1/animals/",
            {
                "animal_id_number": "AN003",
                "name": "Maya",
                "type": "Cow",
                "default_daily_milk": "10.00",
            },
            format="json",
        )
        dashboard_response = self.client.get("/api/v1/dashboard/today/")

        self.assertEqual(animal_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(
            str(dashboard_response.data["milk_production"]["total_liters"]),
            "10.00",
        )

        self.client.post(
            "/api/v1/milk-production/",
            {
                "animal": animal_response.data["id"],
                "production_date": dashboard_response.data["date"],
                "morning_milk": "7.00",
                "evening_milk": "0.00",
                "quality_grade": "A",
            },
            format="json",
        )
        updated_dashboard = self.client.get("/api/v1/dashboard/today/")

        self.assertEqual(
            float(updated_dashboard.data["milk_production"]["total_liters"]),
            7.0,
        )
