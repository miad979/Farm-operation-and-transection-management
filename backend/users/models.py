from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    phone = models.CharField(max_length=20, blank=True)
    farm_name = models.CharField(max_length=255, blank=True)
    farm_location = models.CharField(max_length=255, blank=True)
    owner_name = models.CharField(max_length=255, blank=True)
    language_preference = models.CharField(max_length=10, default="bn")

    def __str__(self):
        return self.username
