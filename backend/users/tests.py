from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase

User = get_user_model()


class AuthApiTests(APITestCase):
    def test_register_user(self):
        payload = {
            "username": "farmer_auth",
            "email": "farmer_auth@example.com",
            "password": "strongpass123",
            "farm_name": "Auth Farm",
        }
        response = self.client.post("/api/v1/auth/register/", payload, format="json")

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(User.objects.filter(username="farmer_auth").exists())

    def test_login_returns_jwt_tokens(self):
        User.objects.create_user(
            username="farmer_login",
            email="farmer_login@example.com",
            password="strongpass123",
        )

        payload = {"username": "farmer_login", "password": "strongpass123"}
        response = self.client.post("/api/v1/auth/login/", payload, format="json")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.data)
        self.assertIn("refresh", response.data)
