from django.urls import path

from .views import CashFlowView, InsightsView, MonthlySummaryView, TodaySummaryView

urlpatterns = [
    path("today/", TodaySummaryView.as_view(), name="dashboard-today"),
    path("monthly/", MonthlySummaryView.as_view(), name="dashboard-monthly"),
    path("insights/", InsightsView.as_view(), name="dashboard-insights"),
    path("cash-flow/", CashFlowView.as_view(), name="dashboard-cashflow"),
]
