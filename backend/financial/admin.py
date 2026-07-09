from django.contrib import admin

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

admin.site.register(Sale)
admin.site.register(Expense)
admin.site.register(FamilyWithdrawal)
admin.site.register(PersonalTransaction)
admin.site.register(CapitalContribution)
admin.site.register(Loan)
admin.site.register(LoanPayment)
admin.site.register(Inventory)
