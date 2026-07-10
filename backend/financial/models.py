from django.conf import settings
from django.db import models

from animals.models import Animal


class Sale(models.Model):
    SALE_TYPE_CHOICES = (("milk", "milk"), ("cattle", "cattle"), ("other", "other"))
    PAYMENT_CHOICES = (
        ("cash", "cash"),
        ("bank_transfer", "bank_transfer"),
        ("check", "check"),
    )

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    sale_type = models.CharField(max_length=20, choices=SALE_TYPE_CHOICES)
    sale_date = models.DateField()
    customer_name = models.CharField(max_length=100, blank=True)
    customer_phone = models.CharField(max_length=20, blank=True)
    description = models.CharField(max_length=255, blank=True)
    quantity = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    unit = models.CharField(max_length=20, blank=True)
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    total_amount = models.DecimalField(max_digits=12, decimal_places=2)
    paid_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    payment_method = models.CharField(max_length=20, choices=PAYMENT_CHOICES, blank=True)
    reference_animal = models.ForeignKey(
        Animal, on_delete=models.SET_NULL, null=True, blank=True, related_name="sale_records"
    )
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-sale_date", "-created_at"]


class Expense(models.Model):
    CATEGORY_CHOICES = (
        ("feed", "feed"),
        ("medicine", "medicine"),
        ("veterinary", "veterinary"),
        ("salary", "salary"),
        ("transport", "transport"),
        ("electricity", "electricity"),
        ("maintenance", "maintenance"),
        ("miscellaneous", "miscellaneous"),
    )
    PAYMENT_CHOICES = (
        ("cash", "cash"),
        ("bank_transfer", "bank_transfer"),
        ("check", "check"),
    )

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    expense_date = models.DateField()
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    description = models.CharField(max_length=255, blank=True)
    receipt_image_url = models.URLField(blank=True)
    vendor_name = models.CharField(max_length=100, blank=True)
    payment_method = models.CharField(max_length=20, choices=PAYMENT_CHOICES, blank=True)
    notes = models.TextField(blank=True)
    is_recurring = models.BooleanField(default=False)
    recurring_frequency = models.CharField(max_length=20, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-expense_date", "-created_at"]


class FamilyWithdrawal(models.Model):
    REASON_CHOICES = (
        ("household", "household"),
        ("medical", "medical"),
        ("education", "education"),
        ("personal", "personal"),
        ("other", "other"),
    )

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    withdrawal_date = models.DateField()
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    reason = models.CharField(max_length=100, choices=REASON_CHOICES, blank=True)
    description = models.CharField(max_length=255, blank=True)
    approved_by = models.CharField(max_length=100, blank=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-withdrawal_date", "-created_at"]


class PersonalTransaction(models.Model):
    TRANSACTION_TYPE_CHOICES = (
        ("income", "income"),
        ("expense", "expense"),
        ("farm_transfer", "farm_transfer"),
    )
    CATEGORY_CHOICES = (
        ("salary", "salary"),
        ("household", "household"),
        ("medical", "medical"),
        ("education", "education"),
        ("food", "food"),
        ("transport", "transport"),
        ("savings", "savings"),
        ("farm_transfer", "farm_transfer"),
        ("other", "other"),
    )

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    transaction_date = models.DateField()
    transaction_type = models.CharField(max_length=20, choices=TRANSACTION_TYPE_CHOICES)
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, blank=True)
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    description = models.CharField(max_length=255, blank=True)
    source_withdrawal = models.OneToOneField(
        FamilyWithdrawal,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="personal_transaction",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-transaction_date", "-created_at"]


class CapitalContribution(models.Model):
    SOURCE_CHOICES = (
        ("owner", "owner"),
        ("investor", "investor"),
        ("partner", "partner"),
        ("other", "other"),
    )
    PAYMENT_CHOICES = (
        ("cash", "cash"),
        ("bank_transfer", "bank_transfer"),
        ("check", "check"),
    )

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    contribution_date = models.DateField()
    source_type = models.CharField(max_length=20, choices=SOURCE_CHOICES, default="owner")
    contributor_name = models.CharField(max_length=100, blank=True)
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    payment_method = models.CharField(max_length=20, choices=PAYMENT_CHOICES, blank=True)
    description = models.CharField(max_length=255, blank=True)
    expected_return_note = models.CharField(max_length=255, blank=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-contribution_date", "-created_at"]


class Loan(models.Model):
    INTEREST_TYPE_CHOICES = (("simple", "simple"), ("compound", "compound"))
    STATUS_CHOICES = (("active", "active"), ("closed", "closed"), ("defaulted", "defaulted"))

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    loan_amount = models.DecimalField(max_digits=12, decimal_places=2)
    loan_source = models.CharField(max_length=100, blank=True)
    loan_date = models.DateField()
    interest_rate = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    interest_type = models.CharField(max_length=20, choices=INTEREST_TYPE_CHOICES, default="simple")
    tenure_months = models.IntegerField(null=True, blank=True)
    monthly_installment = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    repayment_start_date = models.DateField(null=True, blank=True)
    outstanding_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    paid_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="active")
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-loan_date", "-created_at"]

    def save(self, *args, **kwargs):
        if not self.outstanding_amount:
            self.outstanding_amount = self.loan_amount
        super().save(*args, **kwargs)


class LoanPayment(models.Model):
    PAYMENT_CHOICES = (
        ("cash", "cash"),
        ("bank_transfer", "bank_transfer"),
        ("check", "check"),
    )

    loan = models.ForeignKey(Loan, on_delete=models.CASCADE, related_name="payments")
    payment_date = models.DateField()
    principal_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    interest_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    total_payment = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    payment_method = models.CharField(max_length=20, choices=PAYMENT_CHOICES, blank=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-payment_date", "-created_at"]

    def save(self, *args, **kwargs):
        if not self.total_payment:
            self.total_payment = (self.principal_amount or 0) + (self.interest_amount or 0)
        super().save(*args, **kwargs)


class Inventory(models.Model):
    ITEM_TYPE_CHOICES = (
        ("feed", "feed"),
        ("medicine", "medicine"),
        ("equipment", "equipment"),
        ("other", "other"),
    )

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    item_type = models.CharField(max_length=50, choices=ITEM_TYPE_CHOICES)
    item_name = models.CharField(max_length=100)
    quantity = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    unit = models.CharField(max_length=20, blank=True)
    reorder_level = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    daily_usage_quantity = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    auto_deduct_enabled = models.BooleanField(default=False)
    last_auto_deducted = models.DateField(null=True, blank=True)
    cost_per_unit = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    supplier_name = models.CharField(max_length=100, blank=True)
    last_updated = models.DateField(null=True, blank=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["item_name"]
