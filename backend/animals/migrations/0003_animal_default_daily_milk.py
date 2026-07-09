from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("animals", "0002_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="animal",
            name="default_daily_milk",
            field=models.DecimalField(decimal_places=2, default=0, max_digits=8),
        ),
    ]
