from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ("animals", "0003_animal_default_daily_milk"),
    ]

    operations = [
        migrations.CreateModel(
            name="MilkProductionRate",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("daily_milk", models.DecimalField(decimal_places=2, default=0, max_digits=8)),
                ("effective_date", models.DateField()),
                ("notes", models.TextField(blank=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("animal", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="milk_rates", to="animals.animal")),
                ("user", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
            options={
                "ordering": ["-effective_date", "-created_at"],
                "unique_together": {("animal", "effective_date")},
            },
        ),
    ]
