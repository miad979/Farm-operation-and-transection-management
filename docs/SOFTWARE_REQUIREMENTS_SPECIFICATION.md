# Software Requirements Specification

## 1. Purpose

DairyOps is a mobile-first farm operation and transaction management system for dairy and cattle farms. It helps a non-technical farm owner record daily animal, milk, sales, cost, stock, personal money, and history data from a phone.

## 2. Scope

The system includes:

- Flutter mobile/web/desktop frontend
- Django REST backend for online accounts
- Offline phone mode for internet-free daily use
- Local phone backup/restore
- Dashboard, records, history, reports, and search

The system does not currently include:

- Automatic cloud sync between offline and online mode
- Multi-user role permissions inside one farm
- Payment gateway integration
- Real SMS/WhatsApp reminders

## 3. User Types

Farm owner:

- Adds animals, sales, costs, personal money, and stock
- Checks farm cash and customer dues
- Uses offline mode when internet is unavailable

Farm helper:

- May record milk, feed usage, or expenses
- Needs simple labels and low-complexity forms

Developer/admin:

- Runs backend and frontend
- Manages releases and production API configuration

## 4. Functional Requirements

### Authentication

- User can register with username, email, password, and farm name.
- User can log in with username and password.
- Authenticated API requests use JWT access tokens.
- User can use offline phone mode without account creation.

### Animals

- User can add, edit, and list animals.
- User can record animal ID, name, type, breed, health, vaccination, pregnancy, normal daily milk, and notes.
- User can mark an animal inactive when sold.
- User can search animals by name, ID, and type.

### Milk Production

- User can record milk by animal and date.
- One cow should have only one milk record per day.
- If same cow and date are recorded again, the old record is updated instead of double-counted.
- User can delete a wrong milk record with a reason.
- Animal normal daily milk can be used for automatic daily production summary.

### Sales And Customer Dues

- User can record milk sales, cattle sales, and other sales.
- User can record customer name and phone.
- User can record bill amount and paid amount.
- System calculates due amount.
- Dashboard shows customer dues.
- Cattle sale should mark the animal inactive.

### Farm Expenses

- User can record farm spending by category.
- Expenses reduce farm cash and profit.

### Personal Money

- User can take money from farm to pocket.
- Farm-to-pocket transfer reduces farm cash and increases personal money.
- User can record personal income and personal expenses.

### Capital / Farm Money

- User can add owner, investor, partner, or other farm money.
- Added farm money increases farm cash but is not counted as sales income.

### Loans

- User can record loans.
- User can record loan payments.
- System tracks paid and outstanding loan amount.

### Feed And Stock

- User can add feed, medicine, equipment, or other stock.
- User can set current quantity, unit, reorder warning level, and daily use.
- System can auto-deduct daily stock usage.
- User can manually add or reduce stock.

### History, Search, And Reports

- User can view record history by category.
- User can search history by name, date, amount, note, item, or customer.
- User can view daily, monthly, and yearly summaries.
- User can export CSV/PDF where implemented.

### Backup And Restore

- Offline user can copy backup text.
- Offline user can paste backup text and restore records.
- Backup should include all offline farm records.

## 5. Non-Functional Requirements

Usability:

- UI labels must be understandable to non-technical users.
- Important workflows should be reachable from the dashboard.
- Phone screens should avoid dense layouts and heavy rendering.

Performance:

- Phone scrolling should remain smooth with many records.
- Lists should use lazy rendering where possible.
- Heavy charts should be avoided on small phones.

Reliability:

- Offline records must remain after app exit/reopen.
- Wrong duplicate milk entries should not double-count.
- Existing sales must not become unpaid during migrations.

Security:

- Online API must protect user-owned records.
- Production release must use HTTPS backend.
- Secrets, `.env`, keystores, and database files must not be committed.

Compatibility:

- Android minimum SDK is API 23.
- Flutter targets Android, web, desktop, and other supported platforms.

## 6. Acceptance Criteria

- A farmer can use offline mode and save data after app restart.
- A farmer can add a cow, set normal daily milk, and see milk totals.
- Same-day milk edits update instead of double-counting.
- A sale can have a partial payment and appear in customer dues.
- Farm-to-pocket transfer updates both farm and personal money.
- Feed stock can reduce by daily usage.
- History search finds records across categories.
- `flutter analyze`, `flutter test`, and backend tests pass before release.

