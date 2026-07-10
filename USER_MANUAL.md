# DairyOps User Manual

This guide explains how to use the DairyOps app in simple daily language.

## 1. First Start

When you open the app, you can use it in two ways:

- **Use offline on this phone**: Best for most farmers. Records are saved on the phone and the app works without internet.
- **Login / create account**: Use this only when a backend server is running or hosted online.

Important: If you use offline mode, keep phone backups from the app so your data is not lost if the phone is damaged or reset.

## 2. Main Dashboard

The dashboard shows your farm condition for today and this month.

You can see:

- Today profit
- Today milk
- Farm cash
- Available cash
- Animal count
- Customer dues
- Monthly calculation
- Feed/stock warning
- Health and management warnings

Use **What do you want to record?** to quickly add daily records.

## 3. Add Animals

Open **Animals** and tap **Add animal**.

Add details like:

- Animal ID
- Name
- Type, such as cow or calf
- Breed
- Health status
- Vaccination
- Pregnancy status
- Normal daily milk
- Notes

Normal daily milk is important. If a cow normally gives 8 liters per day, set that value. The app can count that automatically unless you change the day value manually.

Use animal search to quickly find a cow by name, ID, or type.

## 4. Milk Production

The app is designed so milk is not counted twice by mistake.

How it works:

- If a cow has normal daily milk, the app can use that as the daily production.
- If production changes today, record the actual milk for that cow.
- If you enter milk twice for the same cow and same day, the newer value updates the old value instead of double-counting.
- If a wrong milk record was saved, you can edit it from History.
- If you delete a milk record, add a reason so the correction remains recorded.

## 5. Sales And Customer Due

Use **Sell** or **Record a sale** when you sell milk, a cow, or another farm item.

Enter:

- What did you sell?
- Customer name
- Customer phone
- Short note
- Bill amount
- Paid now

If the customer pays the full amount, you can leave **Paid now** empty. The app will treat it as fully paid.

If the customer pays less than the bill, the remaining amount appears in **Customer dues**.

Example:

- Bill amount: 1000
- Paid now: 700
- Due: 300

## 6. Farm Spending

Use **Spend money** when the farm pays for something.

Examples:

- Feed
- Medicine
- Vet doctor
- Worker salary
- Transport
- Electricity
- Repair
- Other cost

This reduces farm profit and farm cash.

## 7. Personal Money

Farm money and personal money are separate.

Use **Take to pocket** when you take money from farm cash for family or personal use.

Example:

- You take 2000 from farm.
- Farm cash goes down by 2000.
- Personal pocket money goes up by 2000.

Then personal expenses are handled from the personal money section.

## 8. Add Farm Money

Use **Add farm money** when money is added into the farm.

Examples:

- Owner adds money from pocket
- Investor adds money
- Partner adds money
- Other source adds money

This increases farm cash and is recorded separately from sales.

## 9. Feed And Stock

Use **Add feed stock** to add items like feed, medicine, or equipment.

Enter:

- Feed/item name
- Current amount
- Unit, such as kg
- Warn me below this
- Used per day

If you set **Used per day**, the app can reduce that stock automatically each day. You can still manually add or reduce stock whenever needed.

## 10. History And Search

Open **History** to see older records.

History includes:

- Ledger
- Milk
- Sales
- Farm cost
- Taken money
- Investment/farm money
- Feed/stock

Use **Search records** to find records by:

- Name
- Date
- Amount
- Note
- Item name
- Customer name

You can edit old records from History when something was entered wrong.

## 11. Monthly And Yearly Records

The ledger shows daily, monthly, and yearly information.

Use it to check:

- Milk production by day/month
- Sales income
- Farm cost
- Money taken to pocket
- Farm money added
- Personal income and expense
- Farm cash and personal cash

Monthly calculation carries forward from previous months, so the next month does not start as a fake zero balance.

## 12. Backup And Restore

In offline mode, tap the **Backup** icon on the dashboard.

Use:

- **Copy backup**: Copies your offline data as backup text.
- **Paste from clipboard**: Pastes an old backup.
- **Restore backup**: Restores data from pasted backup text.

Save the copied backup somewhere safe, such as Google Drive, Notes, WhatsApp to yourself, or another phone.

## 13. Bangla / English

Use the language button to switch between English and Bangla labels.

Some technical setup files are in English, but the app is designed so farm users can understand the main daily actions.

## 14. APK And Play Store

The local APK is created here after building:

```text
frontend/build/app/outputs/flutter-apk/app-release.apk
```

For Google Play Store, use an AAB file instead of APK:

```powershell
cd frontend
flutter build appbundle --release
```

The AAB will be created here:

```text
frontend/build/app/outputs/bundle/release/app-release.aab
```

## 15. Daily Recommended Workflow

1. Open Dashboard.
2. Check warnings and cash summary.
3. Add or update animals if needed.
4. Record changed milk production only when normal milk is different.
5. Record sales and paid amount.
6. Record farm spending.
7. Record money taken to pocket if any.
8. Add feed stock or update daily use.
9. Check History when you need old records.
10. Copy backup regularly if using offline mode.

