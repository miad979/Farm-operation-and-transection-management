from datetime import timedelta
from decimal import Decimal

from django.db.models import Sum

from .models import Animal, MilkProduction


def milk_total_with_defaults(user, start_date, end_date=None):
    end_date = end_date or start_date
    records = MilkProduction.objects.filter(
        user=user,
        production_date__gte=start_date,
        production_date__lte=end_date,
    )
    manual_total = records.aggregate(total=Sum("total_milk"))["total"] or Decimal("0")
    manual_pairs = set(records.values_list("animal_id", "production_date"))
    animals = list(
        Animal.objects.filter(user=user, is_active=True, default_daily_milk__gt=0).values(
            "id",
            "default_daily_milk",
        )
    )

    default_total = Decimal("0")
    day = start_date
    while day <= end_date:
        for animal in animals:
            if (animal["id"], day) not in manual_pairs:
                default_total += animal["default_daily_milk"] or Decimal("0")
        day += timedelta(days=1)

    return manual_total + default_total
