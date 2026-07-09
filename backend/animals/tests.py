from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from .milk_totals import milk_total_with_defaults

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

    def test_changing_cow_profile_milk_keeps_previous_rate_history(self):
        today = timezone.localdate()
        animal_response = self.client.post(
            "/api/v1/animals/",
            {
                "animal_id_number": "AN004",
                "name": "Jui",
                "type": "Cow",
                "default_daily_milk": "8.00",
            },
            format="json",
        )
        animal_id = animal_response.data["id"]

        self.client.patch(
            f"/api/v1/animals/{animal_id}/",
            {
                "animal_id_number": "AN004",
                "name": "Jui",
                "type": "Cow",
                "breed": "",
                "gender": "",
                "health_status": "Healthy",
                "default_daily_milk": "11.00",
                "vaccinated": False,
                "pregnancy_status": "Not Pregnant",
                "notes": "",
            },
            format="json",
        )

        self.assertEqual(float(milk_total_with_defaults(self.user, today)), 11.0)

        self.client.post(
            "/api/v1/milk-production/",
            {
                "animal": animal_id,
                "production_date": today.isoformat(),
                "morning_milk": "9.00",
                "evening_milk": "0.00",
                "quality_grade": "A",
            },
            format="json",
        )

        self.assertEqual(float(milk_total_with_defaults(self.user, today)), 9.0)

        self.client.patch(
            f"/api/v1/animals/{animal_id}/",
            {
                "animal_id_number": "AN004",
                "name": "Jui",
                "type": "Cow",
                "breed": "",
                "gender": "",
                "health_status": "Healthy",
                "default_daily_milk": "0.00",
                "vaccinated": False,
                "pregnancy_status": "Not Pregnant",
                "notes": "",
            },
            format="json",
        )

        self.assertEqual(float(milk_total_with_defaults(self.user, today)), 9.0)
