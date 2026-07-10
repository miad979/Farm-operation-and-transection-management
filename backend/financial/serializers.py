from rest_framework import serializers

from .models import (
    CapitalContribution,
    Expense,
    FamilyWithdrawal,
    Inventory,
    Loan,
    LoanPayment,
    PersonalTransaction,
    Sale,
)


class SaleSerializer(serializers.ModelSerializer):
    due_amount = serializers.SerializerMethodField()

    class Meta:
        model = Sale
        exclude = ("user",)

    def get_due_amount(self, obj):
        return max(obj.total_amount - obj.paid_amount, 0)


class ExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Expense
        exclude = ("user",)


class FamilyWithdrawalSerializer(serializers.ModelSerializer):
    class Meta:
        model = FamilyWithdrawal
        exclude = ("user",)


class PersonalTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = PersonalTransaction
        exclude = ("user",)


class CapitalContributionSerializer(serializers.ModelSerializer):
    class Meta:
        model = CapitalContribution
        exclude = ("user",)


class LoanSerializer(serializers.ModelSerializer):
    class Meta:
        model = Loan
        exclude = ("user",)


class LoanPaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = LoanPayment
        fields = "__all__"


class InventorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Inventory
        exclude = ("user",)
