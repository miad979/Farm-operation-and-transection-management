from datetime import date, datetime
from decimal import Decimal

from django.db.models import Sum
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from animals.models import Animal, MilkProduction
from financial.models import CapitalContribution, Expense, FamilyWithdrawal, Loan, PersonalTransaction, Sale


def _sum(queryset, field):
    return queryset.aggregate(total=Sum(field))["total"] or Decimal("0")


def _report_for_period(user, start_date=None, year=None, month=None):
    sales = Sale.objects.filter(user=user)
    expenses = Expense.objects.filter(user=user)
    withdrawals = FamilyWithdrawal.objects.filter(user=user)
    capital = CapitalContribution.objects.filter(user=user)
    personal = PersonalTransaction.objects.filter(user=user)
    milk = MilkProduction.objects.filter(user=user)

    if start_date:
        sales = sales.filter(sale_date=start_date)
        expenses = expenses.filter(expense_date=start_date)
        withdrawals = withdrawals.filter(withdrawal_date=start_date)
        capital = capital.filter(contribution_date=start_date)
        personal = personal.filter(transaction_date=start_date)
        milk = milk.filter(production_date=start_date)
    if year:
        sales = sales.filter(sale_date__year=year)
        expenses = expenses.filter(expense_date__year=year)
        withdrawals = withdrawals.filter(withdrawal_date__year=year)
        capital = capital.filter(contribution_date__year=year)
        personal = personal.filter(transaction_date__year=year)
        milk = milk.filter(production_date__year=year)
    if month:
        sales = sales.filter(sale_date__month=month)
        expenses = expenses.filter(expense_date__month=month)
        withdrawals = withdrawals.filter(withdrawal_date__month=month)
        capital = capital.filter(contribution_date__month=month)
        personal = personal.filter(transaction_date__month=month)
        milk = milk.filter(production_date__month=month)

    income = _sum(sales, "total_amount")
    business_expenses = _sum(expenses, "amount")
    farm_to_pocket = _sum(withdrawals, "amount")
    capital_added = _sum(capital, "amount")
    personal_income = _sum(personal.filter(transaction_type="income"), "amount")
    personal_expenses = _sum(personal.filter(transaction_type="expense"), "amount")
    pocket_from_farm = _sum(personal.filter(transaction_type="farm_transfer"), "amount")

    return {
        "milk_liters": _sum(milk, "total_milk"),
        "animal_count": Animal.objects.filter(user=user, is_active=True).count(),
        "income": income,
        "business_expenses": business_expenses,
        "profit": income - business_expenses,
        "capital_added": capital_added,
        "farm_to_pocket": farm_to_pocket,
        "farm_cash": income - business_expenses - farm_to_pocket + capital_added,
        "personal_income": personal_income,
        "personal_expenses": personal_expenses,
        "personal_balance": personal_income + pocket_from_farm - personal_expenses,
        "active_loans": Loan.objects.filter(user=user, status="active").count(),
        "loan_outstanding": _sum(Loan.objects.filter(user=user), "outstanding_amount"),
    }


class DailyReportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        raw_date = request.query_params.get("date")
        report_date = date.today()
        if raw_date:
            report_date = datetime.strptime(raw_date, "%Y-%m-%d").date()
        return Response({"date": report_date, **_report_for_period(request.user, start_date=report_date)})


class MonthlyReportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = date.today()
        year = int(request.query_params.get("year", today.year))
        month = int(request.query_params.get("month", today.month))
        return Response({"year": year, "month": month, **_report_for_period(request.user, year=year, month=month)})


class YearlyReportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        year = int(request.query_params.get("year", date.today().year))
        return Response({"year": year, **_report_for_period(request.user, year=year)})


class FinancialReportView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(_report_for_period(request.user))
