# Database Design

## 1. Overview

DairyOps stores online data in Django models. Local development can use SQLite, while production should use PostgreSQL. Offline phone mode stores similar record structures in SharedPreferences through `LocalFarmStore`.

## 2. Main Entities

### User

App: `users`

Fields:

- username
- email
- phone
- farm_name
- farm_location
- owner_name
- language_preference

Relationships:

- Owns animals, sales, expenses, withdrawals, personal transactions, capital records, loans, inventory, and milk records.

### Animal

App: `animals`

Fields:

- user
- animal_id_number
- name
- type
- breed
- gender
- purchase_date
- purchase_price
- current_value
- default_daily_milk
- health_status
- vaccinated
- vaccination_date
- pregnancy_status
- expected_delivery_date
- notes
- image_url
- is_active

Rules:

- `animal_id_number` is unique.
- Sold animals should be marked inactive, not deleted.

### MilkProduction

App: `animals`

Fields:

- user
- animal
- production_date
- morning_milk
- evening_milk
- total_milk
- quality_grade
- notes

Rules:

- `total_milk = morning_milk + evening_milk`.
- Unique by `animal` and `production_date`.
- Same-day repeat input updates old record.

### MilkProductionRate

Tracks normal daily milk changes over time.

Fields:

- user
- animal
- daily_milk
- effective_date
- notes

### MilkRecordAudit

Tracks milk record corrections.

Fields:

- user
- animal
- production_date
- action
- old_total_milk
- new_total_milk
- reason

### Sale

App: `financial`

Fields:

- user
- sale_type
- sale_date
- customer_name
- customer_phone
- description
- quantity
- unit
- price_per_unit
- total_amount
- paid_amount
- payment_method
- reference_animal
- notes

Rules:

- Due is calculated as `max(total_amount - paid_amount, 0)`.
- Cattle sale may reference an animal and mark it inactive.
- Migration must preserve old sales as paid.

### Expense

Fields:

- user
- expense_date
- category
- amount
- description
- vendor_name
- payment_method
- notes

Rule:

- Farm expenses reduce farm cash and profit.

### FamilyWithdrawal

Fields:

- user
- withdrawal_date
- amount
- reason
- description

Rule:

- Reduces farm cash.
- Creates/links a personal farm transfer record.

### PersonalTransaction

Fields:

- user
- transaction_date
- transaction_type
- category
- amount
- description
- source_withdrawal

Rules:

- `farm_transfer` increases personal balance.
- `expense` decreases personal balance.
- Personal expenses do not reduce farm cash directly.

### CapitalContribution

Fields:

- user
- contribution_date
- source_type
- contributor_name
- amount
- payment_method
- description

Rule:

- Adds farm cash but is not sales income.

### Loan

Fields:

- user
- loan_amount
- loan_source
- loan_date
- interest_rate
- interest_type
- tenure_months
- monthly_installment
- outstanding_amount
- paid_amount
- status

Rule:

- If `outstanding_amount` is empty on create, it starts as `loan_amount`.

### LoanPayment

Fields:

- loan
- payment_date
- principal_amount
- interest_amount
- total_payment
- payment_method

Rule:

- `total_payment = principal_amount + interest_amount`.
- Paying principal reduces outstanding amount.

### Inventory

Fields:

- user
- item_type
- item_name
- quantity
- unit
- reorder_level
- daily_usage_quantity
- auto_deduct_enabled
- last_auto_deducted
- cost_per_unit
- supplier_name
- notes

Rules:

- Daily auto-use reduces quantity.
- Quantity should not become negative.
- Low stock is when `quantity <= reorder_level`.

## 3. Relationship Summary

```text
User 1--N Animal
User 1--N MilkProduction
Animal 1--N MilkProduction
Animal 1--N MilkProductionRate
Animal 1--N MilkRecordAudit
User 1--N Sale
Animal 0--N Sale as reference_animal
User 1--N Expense
User 1--N FamilyWithdrawal
FamilyWithdrawal 1--0/1 PersonalTransaction
User 1--N PersonalTransaction
User 1--N CapitalContribution
User 1--N Loan
Loan 1--N LoanPayment
User 1--N Inventory
```

## 4. Offline Storage

Offline records are stored as JSON lists under SharedPreferences keys in `LocalFarmStore`.

Offline data groups:

- animals
- sales
- expenses
- withdrawals
- capital
- personal transactions
- loans
- inventory
- milk records
- milk audit
- milk rates

Backup export wraps these groups into one JSON object with app name, version, created date, and data.

