from datetime import datetime

from django.db.models import Avg, Sum
from django.utils import timezone
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Animal, MilkProduction
from .serializers import AnimalSerializer, MilkProductionSerializer


class AnimalViewSet(viewsets.ModelViewSet):
    serializer_class = AnimalSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Animal.objects.filter(user=self.request.user)
        animal_type = self.request.query_params.get("type")
        health_status = self.request.query_params.get("health_status")
        is_active = self.request.query_params.get("is_active")

        if animal_type:
            queryset = queryset.filter(type=animal_type)
        if health_status:
            queryset = queryset.filter(health_status=health_status)
        if is_active is not None:
            queryset = queryset.filter(is_active=is_active.lower() == "true")

        return queryset

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=True, methods=["post"])
    def health(self, request, pk=None):
        animal = self.get_object()
        animal.health_status = request.data.get("health_status", animal.health_status)
        animal.notes = request.data.get("notes", animal.notes)
        animal.save(update_fields=["health_status", "notes", "updated_at"])
        return Response(AnimalSerializer(animal).data)

    @action(detail=True, methods=["post"])
    def vaccinate(self, request, pk=None):
        animal = self.get_object()
        animal.vaccinated = True
        animal.vaccination_date = request.data.get("vaccination_date", str(timezone.localdate()))
        animal.last_vaccination_type = request.data.get(
            "last_vaccination_type", animal.last_vaccination_type
        )
        animal.save(
            update_fields=["vaccinated", "vaccination_date", "last_vaccination_type", "updated_at"]
        )
        return Response(AnimalSerializer(animal).data)

    @action(detail=True, methods=["post"])
    def pregnancy(self, request, pk=None):
        animal = self.get_object()
        animal.pregnancy_status = request.data.get("pregnancy_status", animal.pregnancy_status)
        animal.expected_delivery_date = request.data.get("expected_delivery_date")
        if animal.pregnancy_status.lower() == "pregnant":
            animal.health_status = "Pregnant"
        animal.save(
            update_fields=["pregnancy_status", "expected_delivery_date", "health_status", "updated_at"]
        )
        return Response(AnimalSerializer(animal).data)

    @action(detail=False, methods=["get"])
    def stats(self, request):
        qs = self.get_queryset()
        data = {
            "total": qs.count(),
            "active": qs.filter(is_active=True).count(),
            "healthy": qs.filter(health_status="Healthy").count(),
            "pregnant": qs.filter(health_status="Pregnant").count(),
            "vaccinated": qs.filter(vaccinated=True).count(),
        }
        return Response(data)


class MilkProductionViewSet(viewsets.ModelViewSet):
    serializer_class = MilkProductionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return MilkProduction.objects.filter(user=self.request.user).select_related("animal")

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=False, methods=["get"], url_path=r"daily-report/(?P<report_date>[^/.]+)")
    def daily_report(self, request, report_date=None):
        try:
            parsed_date = datetime.strptime(report_date, "%Y-%m-%d").date()
        except ValueError:
            return Response({"detail": "Use YYYY-MM-DD format."}, status=status.HTTP_400_BAD_REQUEST)

        records = self.get_queryset().filter(production_date=parsed_date)
        total = records.aggregate(total=Sum("total_milk"))["total"] or 0
        avg_per_animal = records.aggregate(avg=Avg("total_milk"))["avg"] or 0
        return Response(
            {
                "date": parsed_date,
                "total_liters": total,
                "count_animals": records.count(),
                "average_per_animal": round(float(avg_per_animal), 2) if avg_per_animal else 0,
            }
        )

    @action(detail=False, methods=["get"], url_path=r"monthly-report/(?P<year>\d{4})/(?P<month>\d{1,2})")
    def monthly_report(self, request, year=None, month=None):
        records = self.get_queryset().filter(production_date__year=year, production_date__month=month)
        total = records.aggregate(total=Sum("total_milk"))["total"] or 0
        best = records.order_by("-total_milk").first()
        return Response(
            {
                "year": int(year),
                "month": int(month),
                "total_liters": total,
                "records": records.count(),
                "best_record": MilkProductionSerializer(best).data if best else None,
            }
        )

    @action(detail=False, methods=["get"], url_path=r"cow/(?P<animal_id>\d+)")
    def cow_history(self, request, animal_id=None):
        records = self.get_queryset().filter(animal_id=animal_id)
        return Response(MilkProductionSerializer(records, many=True).data)

    @action(detail=False, methods=["get"], url_path="best-producer")
    def best_producer(self, request):
        today = timezone.localdate()
        aggregated = (
            self.get_queryset()
            .filter(production_date__year=today.year, production_date__month=today.month)
            .values("animal_id", "animal__name")
            .annotate(total=Sum("total_milk"))
            .order_by("-total")
            .first()
        )
        return Response(aggregated or {"detail": "No records for this month."})
