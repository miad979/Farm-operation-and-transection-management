from django.contrib import admin

from .models import Animal, MilkProduction, MilkProductionRate, MilkRecordAudit


@admin.register(Animal)
class AnimalAdmin(admin.ModelAdmin):
    list_display = (
        "animal_id_number",
        "name",
        "type",
        "default_daily_milk",
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


@admin.register(MilkProductionRate)
class MilkProductionRateAdmin(admin.ModelAdmin):
    list_display = ("animal", "daily_milk", "effective_date", "created_at")
    list_filter = ("effective_date",)
    search_fields = ("animal__name", "animal__animal_id_number")


@admin.register(MilkRecordAudit)
class MilkRecordAuditAdmin(admin.ModelAdmin):
    list_display = ("animal", "production_date", "action", "old_total_milk", "new_total_milk", "created_at")
    list_filter = ("action", "production_date")
    search_fields = ("animal__name", "animal__animal_id_number", "reason")
