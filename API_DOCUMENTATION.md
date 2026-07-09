# Dairy Farm Management System - REST API Documentation

## Base URL
```
http://localhost:8000/api/v1
```

## Authentication
All endpoints (except `/auth/register` and `/auth/login`) require JWT authentication.

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

---

## Authentication Endpoints

### 1. Register User
**Endpoint:** `POST /auth/register/`

**Request:**
```json
{
  "username": "farmer_user",
  "email": "farmer@example.com",
  "password": "securepassword",
  "phone": "+8801700000000",
  "farm_name": "Lakshmi Dairy Farm",
  "farm_location": "Dhaka, Bangladesh",
  "owner_name": "Mohammad Hasan"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "username": "farmer_user",
  "email": "farmer@example.com",
  "farm_name": "Lakshmi Dairy Farm",
  "message": "User registered successfully"
}
```

**Errors:**
- `400 Bad Request`: Validation failed
- `409 Conflict`: Username or email already exists

---

### 2. Login
**Endpoint:** `POST /auth/login/`

**Request:**
```json
{
  "username": "farmer_user",
  "password": "securepassword"
}
```

**Response (200 OK):**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "farmer_user",
    "email": "farmer@example.com",
    "farm_name": "Lakshmi Dairy Farm"
  }
}
```

**Token Expiration:** Access token valid for 1 hour, refresh token for 30 days

---

### 3. Refresh Token
**Endpoint:** `POST /auth/refresh/`

**Request:**
```json
{
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200 OK):**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## Dashboard Endpoints

### 1. Today's Summary
**Endpoint:** `GET /dashboard/today/`

**Response (200 OK):**
```json
{
  "date": "2024-01-15",
  "milk_production": {
    "total_liters": 156,
    "count_cows": 12,
    "average_per_cow": 13.0
  },
  "income": {
    "milk_sales": 7020.00,
    "cattle_sales": 0.00,
    "other_income": 0.00,
    "total": 7020.00
  },
  "expenses": {
    "feed": 800.00,
    "medicine": 500.00,
    "veterinary": 0.00,
    "salary": 2000.00,
    "transport": 300.00,
    "electricity": 150.00,
    "maintenance": 100.00,
    "miscellaneous": 50.00,
    "total": 3900.00
  },
  "profit": 3120.00,
  "cash_balance": 185000.00,
  "family_withdrawals_today": 0.00
}
```

---

### 2. Monthly Summary
**Endpoint:** `GET /dashboard/monthly/?year=2024&month=1`

**Response (200 OK):**
```json
{
  "year": 2024,
  "month": 1,
  "milk_production": {
    "total_liters": 4680,
    "average_daily": 150.97,
    "best_day": "2024-01-15",
    "best_day_liters": 156
  },
  "income": {
    "milk_sales": 210600.00,
    "cattle_sales": 0.00,
    "other_income": 0.00,
    "total": 210600.00
  },
  "expenses": {
    "feed": 24000.00,
    "medicine": 15000.00,
    "veterinary": 5000.00,
    "salary": 60000.00,
    "transport": 9000.00,
    "electricity": 4500.00,
    "maintenance": 3000.00,
    "miscellaneous": 1500.00,
    "total": 122000.00
  },
  "profit": 88600.00,
  "family_withdrawals": 15000.00,
  "business_cash": 170000.00
}
```

---

### 3. Smart Insights
**Endpoint:** `GET /dashboard/insights/`

**Response (200 OK):**
```json
{
  "insights": [
    {
      "type": "production_change",
      "title": "দুধ উৎপাদন বৃদ্ধি",
      "message": "এই মাসে দুধ উৎপাদন গত মাসের চেয়ে ১২% বেশি",
      "percentage": 12.5,
      "status": "positive"
    },
    {
      "type": "feed_cost_change",
      "title": "খাবারের খরচ",
      "message": "খাবারের খরচ গত মাসের চেয়ে ৫% বেশি",
      "percentage": 5.2,
      "status": "warning"
    },
    {
      "type": "best_performer",
      "title": "সেরা দুধ উৎপাদনকারী গাভী",
      "message": "লক্ষ্মী এই মাসে সবচেয়ে বেশি দুধ দিয়েছে (৫২০ লিটার)",
      "animal_name": "Lakshmi",
      "production": 520
    }
  ]
}
```

---

## Cattle Management Endpoints

### 1. List All Animals
**Endpoint:** `GET /animals/?page=1&limit=20&type=Cow`

**Query Parameters:**
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20)
- `type`: Filter by type (Cow, Ox, Calf, etc.)
- `health_status`: Filter by health status
- `is_active`: Filter by active status (default: true)

**Response (200 OK):**
```json
{
  "count": 12,
  "next": "http://localhost:8000/api/v1/animals/?page=2",
  "previous": null,
  "results": [
    {
      "id": 1,
      "animal_id_number": "LF001",
      "name": "Lakshmi",
      "type": "Cow",
      "breed": "Holstein",
      "gender": "Female",
      "purchase_date": "2022-05-15",
      "purchase_price": 45000.00,
      "current_value": 48000.00,
      "health_status": "Healthy",
      "vaccinated": true,
      "vaccination_date": "2024-01-10",
      "last_vaccination_type": "Brucellosis",
      "pregnancy_status": "Not Pregnant",
      "notes": "High milk producer",
      "image_url": "https://s3.amazonaws.com/...",
      "created_at": "2022-05-15T10:30:00Z"
    }
  ]
}
```

---

### 2. Add New Animal
**Endpoint:** `POST /animals/`

**Request:**
```json
{
  "animal_id_number": "LF002",
  "name": "Radha",
  "type": "Cow",
  "breed": "Gir",
  "gender": "Female",
  "purchase_date": "2023-08-20",
  "purchase_price": 50000.00,
  "current_value": 50000.00,
  "health_status": "Healthy",
  "vaccinated": false,
  "notes": "Newborn addition to the herd"
}
```

**Response (201 Created):**
```json
{
  "id": 13,
  "animal_id_number": "LF002",
  "name": "Radha",
  "type": "Cow",
  "breed": "Gir",
  "gender": "Female",
  "purchase_date": "2023-08-20",
  "purchase_price": 50000.00,
  "current_value": 50000.00,
  "health_status": "Healthy",
  "vaccinated": false,
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Validation Errors (400):**
```json
{
  "name": ["This field may not be blank."],
  "type": ["Invalid choice: Type must be Cow, Ox, Calf, etc."],
  "purchase_price": ["Ensure this value is greater than or equal to 0."]
}
```

---

### 3. Get Animal Details
**Endpoint:** `GET /animals/{id}/`

**Response (200 OK):**
```json
{
  "id": 1,
  "animal_id_number": "LF001",
  "name": "Lakshmi",
  "type": "Cow",
  "breed": "Holstein",
  "gender": "Female",
  "purchase_date": "2022-05-15",
  "purchase_price": 45000.00,
  "current_value": 48000.00,
  "health_status": "Healthy",
  "vaccinated": true,
  "vaccination_date": "2024-01-10",
  "last_vaccination_type": "Brucellosis",
  "pregnancy_status": "Pregnant - Day 180",
  "expected_delivery_date": "2024-03-15",
  "notes": "High milk producer, expecting calf soon",
  "image_url": "https://s3.amazonaws.com/...",
  "created_at": "2022-05-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

---

### 4. Update Animal
**Endpoint:** `PUT /animals/{id}/`

**Request:**
```json
{
  "health_status": "Treatment",
  "notes": "Under antibiotic treatment"
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Lakshmi",
  "health_status": "Treatment",
  "notes": "Under antibiotic treatment",
  "updated_at": "2024-01-15T11:00:00Z"
}
```

---

### 5. Record Vaccination
**Endpoint:** `POST /animals/{id}/vaccinate/`

**Request:**
```json
{
  "vaccination_type": "FMD",
  "vaccination_date": "2024-01-15",
  "next_due_date": "2025-01-15"
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Lakshmi",
  "vaccination_date": "2024-01-15",
  "last_vaccination_type": "FMD",
  "vaccinated": true,
  "message": "Vaccination recorded successfully"
}
```

---

### 6. Update Pregnancy Status
**Endpoint:** `POST /animals/{id}/pregnancy/`

**Request:**
```json
{
  "status": "Pregnant",
  "pregnancy_start_date": "2023-09-30",
  "expected_delivery_date": "2024-03-15"
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Lakshmi",
  "pregnancy_status": "Pregnant - Day 107",
  "expected_delivery_date": "2024-03-15",
  "message": "Pregnancy record updated"
}
```

---

### 7. Animal History
**Endpoint:** `GET /animals/{id}/history/`

**Response (200 OK):**
```json
{
  "animal": {
    "id": 1,
    "name": "Lakshmi",
    "type": "Cow"
  },
  "milk_production": {
    "total_lifetime": 5200,
    "monthly_average": 520,
    "last_month": {
      "total": 520,
      "best_day": 26,
      "worst_day": 20
    }
  },
  "health_records": [
    {
      "date": "2024-01-10",
      "status": "Healthy",
      "notes": "Routine vaccination"
    }
  ],
  "sales": {
    "status": "Not sold",
    "if_sold": null
  },
  "purchases": {
    "date": "2022-05-15",
    "price": 45000.00,
    "current_value": 48000.00
  }
}
```

---

## Milk Production Endpoints

### 1. Record Milk Production
**Endpoint:** `POST /milk-production/`

**Request:**
```json
{
  "animal_id": 1,
  "production_date": "2024-01-15",
  "morning_milk": 12.5,
  "evening_milk": 13.5,
  "quality_grade": "A",
  "notes": "Good quality milk"
}
```

**Response (201 Created):**
```json
{
  "id": 1500,
  "animal_id": 1,
  "animal_name": "Lakshmi",
  "production_date": "2024-01-15",
  "morning_milk": 12.5,
  "evening_milk": 13.5,
  "total_milk": 26.0,
  "quality_grade": "A",
  "notes": "Good quality milk",
  "created_at": "2024-01-15T18:30:00Z"
}
```

---

### 2. List Milk Production Records
**Endpoint:** `GET /milk-production/?animal_id=1&start_date=2024-01-01&end_date=2024-01-31&page=1`

**Query Parameters:**
- `animal_id`: Filter by animal (optional)
- `start_date`: Start date (YYYY-MM-DD)
- `end_date`: End date (YYYY-MM-DD)
- `page`: Page number (default: 1)

**Response (200 OK):**
```json
{
  "count": 31,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1500,
      "animal_id": 1,
      "animal_name": "Lakshmi",
      "production_date": "2024-01-15",
      "morning_milk": 12.5,
      "evening_milk": 13.5,
      "total_milk": 26.0,
      "quality_grade": "A",
      "created_at": "2024-01-15T18:30:00Z"
    }
  ]
}
```

---

### 3. Daily Production Report
**Endpoint:** `GET /milk-production/daily-report/?date=2024-01-15`

**Response (200 OK):**
```json
{
  "report_date": "2024-01-15",
  "total_production": 156,
  "number_of_cows_milked": 12,
  "average_per_cow": 13.0,
  "quality_grade_distribution": {
    "A": 8,
    "B": 3,
    "C": 1
  },
  "animals": [
    {
      "animal_id": 1,
      "animal_name": "Lakshmi",
      "morning_milk": 12.5,
      "evening_milk": 13.5,
      "total_milk": 26.0,
      "quality_grade": "A"
    }
  ]
}
```

---

### 4. Monthly Production Report
**Endpoint:** `GET /milk-production/monthly-report/?year=2024&month=1`

**Response (200 OK):**
```json
{
  "year": 2024,
  "month": 1,
  "total_production": 4680,
  "number_of_days": 31,
  "average_daily": 150.97,
  "best_day": {
    "date": "2024-01-15",
    "production": 156
  },
  "worst_day": {
    "date": "2024-01-08",
    "production": 142
  },
  "animals": [
    {
      "animal_id": 1,
      "animal_name": "Lakshmi",
      "total_production": 520,
      "average_daily": 16.77,
      "best_day_production": 26,
      "worst_day_production": 20
    }
  ]
}
```

---

### 5. Best Producer
**Endpoint:** `GET /milk-production/best-producer/?year=2024&month=1`

**Response (200 OK):**
```json
{
  "animal_id": 1,
  "animal_name": "Lakshmi",
  "animal_type": "Cow",
  "breed": "Holstein",
  "total_production": 520,
  "average_daily": 16.77,
  "percentage_of_farm_production": 11.1,
  "consecutive_months_top_producer": 3
}
```

---

## Sales Endpoints

### 1. Record Milk Sale
**Endpoint:** `POST /sales/`

**Request:**
```json
{
  "sale_type": "milk",
  "sale_date": "2024-01-15",
  "customer_name": "Local Dairy Cooperative",
  "customer_phone": "+8801700000000",
  "quantity": 50,
  "unit": "liter",
  "price_per_unit": 45.00,
  "payment_method": "cash",
  "notes": "Regular customer, payment on time"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "sale_type": "milk",
  "sale_date": "2024-01-15",
  "customer_name": "Local Dairy Cooperative",
  "quantity": 50,
  "unit": "liter",
  "price_per_unit": 45.00,
  "total_amount": 2250.00,
  "payment_method": "cash",
  "created_at": "2024-01-15T10:30:00Z"
}
```

---

### 2. Record Cattle Sale
**Endpoint:** `POST /sales/`

**Request:**
```json
{
  "sale_type": "cattle",
  "sale_date": "2024-01-14",
  "customer_name": "Mohammad Karim",
  "customer_phone": "+8801712345678",
  "description": "Young bull - excellent breed",
  "reference_animal_id": 5,
  "total_amount": 35000.00,
  "payment_method": "bank_transfer",
  "notes": "Exported to cattle market"
}
```

**Response (201 Created):**
```json
{
  "id": 2,
  "sale_type": "cattle",
  "sale_date": "2024-01-14",
  "customer_name": "Mohammad Karim",
  "description": "Young bull - excellent breed",
  "animal_sold": {
    "id": 5,
    "name": "Bull-3",
    "type": "Bull",
    "purchase_price": 25000.00
  },
  "total_amount": 35000.00,
  "profit": 10000.00,
  "payment_method": "bank_transfer",
  "created_at": "2024-01-14T15:45:00Z"
}
```

---

### 3. List Sales
**Endpoint:** `GET /sales/?sale_type=milk&start_date=2024-01-01&end_date=2024-01-31&page=1`

**Response (200 OK):**
```json
{
  "count": 30,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "sale_type": "milk",
      "sale_date": "2024-01-15",
      "customer_name": "Local Dairy Cooperative",
      "quantity": 50,
      "unit": "liter",
      "price_per_unit": 45.00,
      "total_amount": 2250.00,
      "payment_method": "cash"
    }
  ]
}
```

---

### 4. Sales Report
**Endpoint:** `GET /sales/report/?year=2024&month=1`

**Response (200 OK):**
```json
{
  "year": 2024,
  "month": 1,
  "total_income": 210600.00,
  "milk_sales": {
    "total_liters": 4680,
    "total_amount": 210600.00,
    "average_price_per_liter": 45.00,
    "number_of_transactions": 30,
    "top_customer": "Local Dairy Cooperative"
  },
  "cattle_sales": {
    "total_amount": 0.00,
    "number_of_sales": 0,
    "animals_sold": []
  }
}
```

---

## Expense Endpoints

### 1. Record Expense
**Endpoint:** `POST /expenses/`

**Request:**
```json
{
  "expense_date": "2024-01-15",
  "category": "feed",
  "amount": 800.00,
  "description": "5 bags of cattle feed",
  "vendor_name": "Ahmed's Feed Store",
  "payment_method": "cash",
  "notes": "Usual monthly purchase"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "expense_date": "2024-01-15",
  "category": "feed",
  "amount": 800.00,
  "description": "5 bags of cattle feed",
  "vendor_name": "Ahmed's Feed Store",
  "payment_method": "cash",
  "created_at": "2024-01-15T10:30:00Z"
}
```

---

### 2. List Expenses
**Endpoint:** `GET /expenses/?category=feed&start_date=2024-01-01&end_date=2024-01-31&page=1`

**Response (200 OK):**
```json
{
  "count": 50,
  "next": "http://localhost:8000/api/v1/expenses/?page=2",
  "previous": null,
  "results": [
    {
      "id": 1,
      "expense_date": "2024-01-15",
      "category": "feed",
      "amount": 800.00,
      "description": "5 bags of cattle feed",
      "vendor_name": "Ahmed's Feed Store"
    }
  ]
}
```

---

### 3. Expense Report by Category
**Endpoint:** `GET /expenses/report/?year=2024&month=1`

**Response (200 OK):**
```json
{
  "year": 2024,
  "month": 1,
  "total_expenses": 122000.00,
  "breakdown": {
    "feed": {
      "amount": 24000.00,
      "percentage": 19.7,
      "transactions": 31
    },
    "salary": {
      "amount": 60000.00,
      "percentage": 49.2,
      "transactions": 2
    },
    "medicine": {
      "amount": 15000.00,
      "percentage": 12.3,
      "transactions": 10
    },
    "veterinary": {
      "amount": 5000.00,
      "percentage": 4.1,
      "transactions": 2
    },
    "transport": {
      "amount": 9000.00,
      "percentage": 7.4,
      "transactions": 5
    },
    "electricity": {
      "amount": 4500.00,
      "percentage": 3.7,
      "transactions": 1
    },
    "maintenance": {
      "amount": 3000.00,
      "percentage": 2.5,
      "transactions": 2
    },
    "miscellaneous": {
      "amount": 1500.00,
      "percentage": 1.2,
      "transactions": 3
    }
  }
}
```

---

## Family Withdrawal Endpoints

### 1. Record Withdrawal
**Endpoint:** `POST /withdrawals/`

**Request:**
```json
{
  "withdrawal_date": "2024-01-15",
  "amount": 5000.00,
  "reason": "household",
  "description": "Household groceries and utilities",
  "notes": "Monthly household expenses"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "withdrawal_date": "2024-01-15",
  "amount": 5000.00,
  "reason": "household",
  "description": "Household groceries and utilities",
  "created_at": "2024-01-15T10:30:00Z"
}
```

---

### 2. List Withdrawals
**Endpoint:** `GET /withdrawals/?reason=household&start_date=2024-01-01&end_date=2024-01-31`

**Response (200 OK):**
```json
{
  "count": 5,
  "results": [
    {
      "id": 1,
      "withdrawal_date": "2024-01-15",
      "amount": 5000.00,
      "reason": "household",
      "description": "Household groceries and utilities"
    }
  ]
}
```

---

### 3. Withdrawal Summary
**Endpoint:** `GET /withdrawals/summary/?year=2024&month=1`

**Response (200 OK):**
```json
{
  "year": 2024,
  "month": 1,
  "total_withdrawals": 15000.00,
  "number_of_withdrawals": 3,
  "average_withdrawal": 5000.00,
  "breakdown": {
    "household": 5000.00,
    "medical": 7000.00,
    "education": 2000.00,
    "personal": 1000.00,
    "other": 0.00
  }
}
```

---

## Loan Endpoints

### 1. Create Loan
**Endpoint:** `POST /loans/`

**Request:**
```json
{
  "loan_amount": 200000.00,
  "loan_source": "Grameen Bank",
  "loan_date": "2023-06-15",
  "interest_rate": 12.5,
  "interest_type": "simple",
  "tenure_months": 24,
  "repayment_start_date": "2023-07-15"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "loan_amount": 200000.00,
  "loan_source": "Grameen Bank",
  "loan_date": "2023-06-15",
  "interest_rate": 12.5,
  "tenure_months": 24,
  "monthly_installment": 9375.00,
  "outstanding_amount": 200000.00,
  "paid_amount": 0.00,
  "status": "active",
  "created_at": "2023-06-15T10:30:00Z"
}
```

---

### 2. Record Loan Payment
**Endpoint:** `POST /loans/{id}/payment/`

**Request:**
```json
{
  "payment_date": "2024-01-15",
  "principal_amount": 8333.33,
  "interest_amount": 2083.33,
  "total_payment": 10416.66,
  "payment_method": "bank_transfer"
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "payment_date": "2024-01-15",
  "principal_amount": 8333.33,
  "interest_amount": 2083.33,
  "total_payment": 10416.66,
  "outstanding_amount": 191666.67,
  "remaining_installments": 19,
  "message": "Payment recorded successfully"
}
```

---

### 3. Loan Payment Schedule
**Endpoint:** `GET /loans/{id}/schedule/`

**Response (200 OK):**
```json
{
  "loan_id": 1,
  "loan_amount": 200000.00,
  "total_interest": 50000.00,
  "total_repayment": 250000.00,
  "schedule": [
    {
      "installment_number": 1,
      "due_date": "2023-07-15",
      "principal": 8333.33,
      "interest": 2083.33,
      "total": 10416.66,
      "outstanding_balance": 191666.67,
      "status": "paid"
    },
    {
      "installment_number": 2,
      "due_date": "2023-08-15",
      "principal": 8333.33,
      "interest": 2083.33,
      "total": 10416.66,
      "outstanding_balance": 183333.34,
      "status": "paid"
    }
  ]
}
```

---

## Report Endpoints

### 1. Daily Profit Report
**Endpoint:** `GET /reports/daily/?date=2024-01-15`

**Response (200 OK):**
```json
{
  "report_date": "2024-01-15",
  "income": 7020.00,
  "expenses": 3900.00,
  "profit": 3120.00,
  "profit_margin": "44.4%",
  "breakdown": {
    "milk_production": 156,
    "income_sources": {
      "milk_sales": 7020.00
    },
    "expense_categories": {
      "feed": 800.00,
      "medicine": 500.00,
      "salary": 2000.00,
      "transport": 300.00,
      "electricity": 150.00,
      "maintenance": 100.00,
      "miscellaneous": 50.00
    }
  }
}
```

---

### 2. Monthly Report
**Endpoint:** `GET /reports/monthly/?year=2024&month=1`

**Response (200 OK):**
```json
{
  "year": 2024,
  "month": 1,
  "income": 210600.00,
  "expenses": 122000.00,
  "profit": 88600.00,
  "profit_margin": "42.1%",
  "family_withdrawals": 15000.00,
  "business_cash": 73600.00,
  "total_cattle": 12,
  "total_milk_production": 4680,
  "average_daily_production": 150.97
}
```

---

### 3. Export Report as PDF
**Endpoint:** `GET /reports/export/pdf/?year=2024&month=1&type=monthly`

**Response:** PDF file download

---

### 4. Export Report as Excel
**Endpoint:** `GET /reports/export/excel/?year=2024&month=1&type=monthly`

**Response:** Excel file download

---

## Error Handling

### Common Error Responses

**401 Unauthorized (Missing or Invalid Token)**
```json
{
  "detail": "Authentication credentials were not provided."
}
```

**403 Forbidden (User accessing another user's data)**
```json
{
  "detail": "You do not have permission to perform this action."
}
```

**404 Not Found**
```json
{
  "detail": "Not found."
}
```

**400 Bad Request (Validation Error)**
```json
{
  "field_name": ["Error message"],
  "another_field": ["Error message 1", "Error message 2"]
}
```

**429 Too Many Requests (Rate Limit)**
```json
{
  "detail": "Request was throttled. Expected available in 60 seconds."
}
```

**500 Internal Server Error**
```json
{
  "detail": "Internal server error. Please try again later."
}
```

---

## Rate Limiting

- **General endpoints**: 100 requests per hour
- **Authentication endpoints**: 10 requests per hour
- **Export endpoints**: 5 requests per hour

---

## Response Pagination

For paginated endpoints, responses follow this format:

```json
{
  "count": 100,
  "next": "http://localhost:8000/api/v1/animals/?page=2",
  "previous": null,
  "results": [...]
}
```

---

## Date Format

All dates must be in `YYYY-MM-DD` format:
```
2024-01-15
```

Time format is ISO 8601:
```
2024-01-15T10:30:00Z
```

---

## Field Validation

### Email
```
farmer@example.com
```

### Phone
```
+8801700000000 or 01700000000
```

### Currency
All monetary values use 2 decimal places:
```
45000.00
```

### Percentage
```
12.5 (meaning 12.5%)
```

---

## Webhook Events (Future Feature)

Coming in v2:
- `sale.created`
- `expense.recorded`
- `animal.sold`
- `vaccination.due`
- `loan.payment_due`
