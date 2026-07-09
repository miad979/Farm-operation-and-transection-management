from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import AnimalViewSet, MilkProductionViewSet

router = DefaultRouter()
router.register(r"animals", AnimalViewSet, basename="animals")
router.register(r"milk-production", MilkProductionViewSet, basename="milk-production")

urlpatterns = [
    path("", include(router.urls)),
]
