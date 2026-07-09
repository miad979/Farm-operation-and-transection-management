from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ("animals", "0004_milkproductionrate"),
    ]

    operations = [
        migrations.CreateModel(
            name="MilkRecordAudit",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("production_date", models.DateField()),
                ("action", models.CharField(choices=[("created", "created"), ("updated", "updated"), ("deleted", "deleted")], max_length=20)),
                ("old_total_milk", models.DecimalField(decimal_places=2, default=0, max_digits=8)),
                ("new_total_milk", models.DecimalField(blank=True, decimal_places=2, max_digits=8, null=True)),
                ("reason", models.TextField(blank=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("animal", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="milk_audits", to="animals.animal")),
                ("user", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
            options={
                "ordering": ["-created_at"],
            },
        ),
    ]
