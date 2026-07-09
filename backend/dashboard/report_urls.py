from django.urls import path

from .reports import DailyReportView, FinancialReportView, MonthlyReportView, YearlyReportView

urlpatterns = [
    path("daily/", DailyReportView.as_view(), name="report-daily"),
    path("monthly/", MonthlyReportView.as_view(), name="report-monthly"),
    path("yearly/", YearlyReportView.as_view(), name="report-yearly"),
    path("financial/", FinancialReportView.as_view(), name="report-financial"),
]
