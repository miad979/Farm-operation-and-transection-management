from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import (
    CapitalContributionViewSet,
    ExpenseViewSet,
    FamilyWithdrawalViewSet,
    InventoryViewSet,
    LoanViewSet,
    PersonalTransactionViewSet,
    SaleViewSet,
)

router = DefaultRouter()
router.register(r"sales", SaleViewSet, basename="sales")
router.register(r"expenses", ExpenseViewSet, basename="expenses")
router.register(r"withdrawals", FamilyWithdrawalViewSet, basename="withdrawals")
router.register(r"personal-transactions", PersonalTransactionViewSet, basename="personal-transactions")
router.register(r"capital", CapitalContributionViewSet, basename="capital")
router.register(r"loans", LoanViewSet, basename="loans")
router.register(r"inventory", InventoryViewSet, basename="inventory")

urlpatterns = [
    path("", include(router.urls)),
]
