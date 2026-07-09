from django.contrib import admin

from .models import Animal, MilkProduction


@admin.register(Animal)
class AnimalAdmin(admin.ModelAdmin):
    list_display = (
        "animal_id_number",
        "name",
        "type",
        "health_status",
        "vaccinated",
        "is_active",
    )
    list_filter = ("type", "health_status", "vaccinated", "is_active")
    search_fields = ("animal_id_number", "name", "breed")


@admin.register(MilkProduction)
class MilkProductionAdmin(admin.ModelAdmin):
    list_display = ("animal", "production_date", "morning_milk", "evening_milk", "total_milk")
    list_filter = ("production_date", "quality_grade")
    search_fields = ("animal__name", "animal__animal_id_number")
