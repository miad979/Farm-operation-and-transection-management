from datetime import timedelta
from decimal import Decimal

from django.db.models import Sum

from .models import Animal, MilkProduction, MilkProductionRate


def milk_total_with_defaults(user, start_date, end_date=None):
    end_date = end_date or start_date
    records = MilkProduction.objects.filter(
        user=user,
        production_date__gte=start_date,
        production_date__lte=end_date,
    )
    manual_total = records.aggregate(total=Sum("total_milk"))["total"] or Decimal("0")
    manual_pairs = set(records.values_list("animal_id", "production_date"))
    animals = list(Animal.objects.filter(user=user, is_active=True).values("id", "default_daily_milk", "created_at"))
    rates = list(
        MilkProductionRate.objects.filter(
            user=user,
            effective_date__lte=end_date,
        )
        .order_by("animal_id", "effective_date")
        .values("animal_id", "daily_milk", "effective_date")
    )
    rates_by_animal = {}
    for rate in rates:
        rates_by_animal.setdefault(rate["animal_id"], []).append(rate)

    default_total = Decimal("0")
    day = start_date
    while day <= end_date:
        for animal in animals:
            if (animal["id"], day) not in manual_pairs:
                default_total += _daily_milk_for_day(
                    animal,
                    rates_by_animal.get(animal["id"], []),
                    day,
                )
        day += timedelta(days=1)

    return manual_total + default_total


def _daily_milk_for_day(animal, rates, day):
    current = None
    for rate in rates:
        if rate["effective_date"] <= day:
            current = rate
        else:
            break
    if current:
        return current["daily_milk"] or Decimal("0")

    created_at = animal.get("created_at")
    created_date = created_at.date() if created_at else day
    if created_date <= day:
        return animal["default_daily_milk"] or Decimal("0")
    return Decimal("0")
