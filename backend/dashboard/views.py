from decimal import Decimal

from django.db.models import Avg, Sum
from django.utils import timezone
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from animals.models import MilkProduction
from financial.models import CapitalContribution, Expense, FamilyWithdrawal, PersonalTransaction, Sale


class TodaySummaryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = timezone.localdate()
        milk_qs = MilkProduction.objects.filter(user=request.user, production_date=today)
        sales_qs = Sale.objects.filter(user=request.user, sale_date=today)
        expenses_qs = Expense.objects.filter(user=request.user, expense_date=today)
        withdrawals_qs = FamilyWithdrawal.objects.filter(user=request.user, withdrawal_date=today)
        capital_qs = CapitalContribution.objects.filter(user=request.user, contribution_date=today)
        personal_qs = PersonalTransaction.objects.filter(user=request.user, transaction_date=today)

        milk_total = milk_qs.aggregate(total=Sum("total_milk"))["total"] or Decimal("0")
        milk_avg = milk_qs.aggregate(avg=Avg("total_milk"))["avg"] or Decimal("0")
        income_total = sales_qs.aggregate(total=Sum("total_amount"))["total"] or Decimal("0")
        expense_total = expenses_qs.aggregate(total=Sum("amount"))["total"] or Decimal("0")
        withdrawals_total = withdrawals_qs.aggregate(total=Sum("amount"))["total"] or Decimal("0")
        capital_total = capital_qs.aggregate(total=Sum("amount"))["total"] or Decimal("0")
        personal_income = personal_qs.filter(transaction_type="income").aggregate(total=Sum("amount"))[
            "total"
        ] or Decimal("0")
        personal_expense = personal_qs.filter(transaction_type="expense").aggregate(total=Sum("amount"))[
            "total"
        ] or Decimal("0")
        farm_to_pocket = personal_qs.filter(transaction_type="farm_transfer").aggregate(total=Sum("amount"))[
            "total"
        ] or Decimal("0")

        return Response(
            {
                "date": today,
                "milk_production": {
                    "total_liters": milk_total,
                    "count_cows": milk_qs.count(),
                    "average_per_cow": round(float(milk_avg), 2) if milk_avg else 0,
                },
                "income": {
                    "total": income_total,
                },
                "expenses": {
                    "total": expense_total,
                },
                "profit": income_total - expense_total,
                "farm_to_pocket_today": withdrawals_total,
                "capital_added_today": capital_total,
                "available_cash_today": (income_total - expense_total) - withdrawals_total + capital_total,
                "personal_money": {
                    "income": personal_income,
                    "expenses": personal_expense,
                    "farm_to_pocket": farm_to_pocket,
                    "balance": personal_income + farm_to_pocket - personal_expense,
                },
            }
        )


class MonthlySummaryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = timezone.localdate()
        year = int(request.query_params.get("year", today.year))
        month = int(request.query_params.get("month", today.month))

        milk_qs = MilkProduction.objects.filter(
            user=request.user,
            production_date__year=year,
            production_date__month=month,
        )
        sales_qs = Sale.objects.filter(user=request.user, sale_date__year=year, sale_date__month=month)
        expenses_qs = Expense.objects.filter(user=request.user, expense_date__year=year, expense_date__month=month)
        withdrawals_qs = FamilyWithdrawal.objects.filter(
            user=request.user,
            withdrawal_date__year=year,
            withdrawal_date__month=month,
        )
        capital_qs = CapitalContribution.objects.filter(
            user=request.user,
            contribution_date__year=year,
            contribution_date__month=month,
        )
        personal_qs = PersonalTransaction.objects.filter(
            user=request.user,
            transaction_date__year=year,
            transaction_date__month=month,
        )

        milk_total = milk_qs.aggregate(total=Sum("total_milk"))["total"] or Decimal("0")
        sales_total = sales_qs.aggregate(total=Sum("total_amount"))["total"] or Decimal("0")
        expenses_total = expenses_qs.aggregate(total=Sum("amount"))["total"] or Decimal("0")
        withdrawals_total = withdrawals_qs.aggregate(total=Sum("amount"))["total"] or Decimal("0")
        capital_total = capital_qs.aggregate(total=Sum("amount"))["total"] or Decimal("0")
        personal_income = personal_qs.filter(transaction_type="income").aggregate(total=Sum("amount"))[
            "total"
        ] or Decimal("0")
        personal_expense = personal_qs.filter(transaction_type="expense").aggregate(total=Sum("amount"))[
            "total"
        ] or Decimal("0")
        farm_to_pocket = personal_qs.filter(transaction_type="farm_transfer").aggregate(total=Sum("amount"))[
            "total"
        ] or Decimal("0")

        return Response(
            {
                "year": year,
                "month": month,
                "milk_production": {
                    "total_liters": milk_total,
                    "average_daily": round(float(milk_total) / max(1, 30), 2),
                },
                "income": {
                    "total": sales_total,
                },
                "expenses": {
                    "total": expenses_total,
                },
                "profit": sales_total - expenses_total,
                "capital_added": capital_total,
                "farm_to_pocket": withdrawals_total,
                "business_cash": (sales_total - expenses_total) - withdrawals_total + capital_total,
                "personal_money": {
                    "income": personal_income,
                    "expenses": personal_expense,
                    "farm_to_pocket": farm_to_pocket,
                    "balance": personal_income + farm_to_pocket - personal_expense,
                },
            }
        )


class InsightsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = timezone.localdate()
        current_month_milk = (
            MilkProduction.objects.filter(
                user=request.user,
                production_date__year=today.year,
                production_date__month=today.month,
            ).aggregate(total=Sum("total_milk"))["total"]
            or Decimal("0")
        )

        last_month = 12 if today.month == 1 else today.month - 1
        last_month_year = today.year - 1 if today.month == 1 else today.year
        previous_month_milk = (
            MilkProduction.objects.filter(
                user=request.user,
                production_date__year=last_month_year,
                production_date__month=last_month,
            ).aggregate(total=Sum("total_milk"))["total"]
            or Decimal("0")
        )

        change = 0
        if previous_month_milk > 0:
            change = round(float((current_month_milk - previous_month_milk) / previous_month_milk * 100), 2)

        best = (
            MilkProduction.objects.filter(
                user=request.user,
                production_date__year=today.year,
                production_date__month=today.month,
            )
            .values("animal__name")
            .annotate(total=Sum("total_milk"))
            .order_by("-total")
            .first()
        )

        insights = [
            {
                "type": "production_change",
                "title": "Milk production change",
                "message": f"This month milk production changed by {change}%",
                "percentage": change,
                "status": "positive" if change >= 0 else "warning",
            }
        ]

        if best:
            insights.append(
                {
                    "type": "best_performer",
                    "title": "Best producing cow",
                    "message": f"{best['animal__name']} produced the highest milk this month",
                    "animal_name": best["animal__name"],
                    "production": best["total"],
                }
            )

        return Response({"insights": insights})


class CashFlowView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        total_income = Sale.objects.filter(user=request.user).aggregate(total=Sum("total_amount"))["total"] or Decimal(
            "0"
        )
        total_expense = Expense.objects.filter(user=request.user).aggregate(total=Sum("amount"))["total"] or Decimal(
            "0"
        )
        total_withdrawal = FamilyWithdrawal.objects.filter(user=request.user).aggregate(total=Sum("amount"))["total"] or Decimal(
            "0"
        )
        total_capital = CapitalContribution.objects.filter(user=request.user).aggregate(total=Sum("amount"))["total"] or Decimal(
            "0"
        )
        personal_qs = PersonalTransaction.objects.filter(user=request.user)
        personal_income = personal_qs.filter(transaction_type="income").aggregate(total=Sum("amount"))[
            "total"
        ] or Decimal("0")
        personal_expense = personal_qs.filter(transaction_type="expense").aggregate(total=Sum("amount"))[
            "total"
        ] or Decimal("0")
        farm_to_pocket = personal_qs.filter(transaction_type="farm_transfer").aggregate(total=Sum("amount"))[
            "total"
        ] or Decimal("0")

        return Response(
            {
                "total_income": total_income,
                "total_business_expense": total_expense,
                "net_profit": total_income - total_expense,
                "capital_added": total_capital,
                "farm_to_pocket": total_withdrawal,
                "available_cash": (total_income - total_expense) - total_withdrawal + total_capital,
                "personal_money": {
                    "income": personal_income,
                    "expenses": personal_expense,
                    "farm_to_pocket": farm_to_pocket,
                    "balance": personal_income + farm_to_pocket - personal_expense,
                },
            }
        )
