from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from .models import User


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    fieldsets = UserAdmin.fieldsets + (
        (
            "Farm Details",
            {
                "fields": (
                    "phone",
                    "farm_name",
                    "farm_location",
                    "owner_name",
                    "language_preference",
                )
            },
        ),
    )
