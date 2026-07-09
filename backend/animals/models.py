from django.conf import settings
from django.db import models


class Animal(models.Model):
    TYPE_CHOICES = (
        ("Cow", "Cow"),
        ("Ox", "Ox"),
        ("Buffalo", "Buffalo"),
        ("Calf", "Calf"),
        ("Heifer", "Heifer"),
        ("Bull", "Bull"),
    )
    HEALTH_CHOICES = (
        ("Healthy", "Healthy"),
        ("Sick", "Sick"),
        ("Treatment", "Treatment"),
        ("Pregnant", "Pregnant"),
    )

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    animal_id_number = models.CharField(max_length=50, unique=True)
    name = models.CharField(max_length=100)
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    breed = models.CharField(max_length=100, blank=True)
    gender = models.CharField(max_length=10, blank=True)
    purchase_date = models.DateField(null=True, blank=True)
    purchase_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    current_value = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    default_daily_milk = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    health_status = models.CharField(max_length=50, choices=HEALTH_CHOICES, default="Healthy")
    vaccinated = models.BooleanField(default=False)
    vaccination_date = models.DateField(null=True, blank=True)
    last_vaccination_type = models.CharField(max_length=100, blank=True)
    pregnancy_status = models.CharField(max_length=50, default="Not Pregnant")
    expected_delivery_date = models.DateField(null=True, blank=True)
    notes = models.TextField(blank=True)
    image_url = models.URLField(blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.animal_id_number} - {self.name}"


class MilkProduction(models.Model):
    QUALITY_CHOICES = (
        ("A", "A"),
        ("B", "B"),
        ("C", "C"),
    )

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    animal = models.ForeignKey(Animal, on_delete=models.CASCADE, related_name="milk_records")
    production_date = models.DateField()
    morning_milk = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    evening_milk = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    total_milk = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    quality_grade = models.CharField(max_length=10, choices=QUALITY_CHOICES, blank=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-production_date", "-created_at"]
        unique_together = ("animal", "production_date")

    def save(self, *args, **kwargs):
        self.total_milk = (self.morning_milk or 0) + (self.evening_milk or 0)
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.animal.name} - {self.production_date}"
