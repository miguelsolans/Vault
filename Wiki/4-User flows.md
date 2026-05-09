# 4. User Flows

This page is the flow index. Each feature page owns the detailed, code-aligned flow so behavior does not drift between documents.

## App Start and First Vault

Owned by: [Features/App-Start-Onboarding-Login.md](Features/App-Start-Onboarding-Login.md), [Features/Vaults.md](Features/Vaults.md)

1. Launch app.
2. Resolve favorite Vault.
3. If missing or invalid, show onboarding.
4. Create Vault.
5. First Vault becomes favorite.
6. If import file was selected, continue to CSV import.
7. Enter private tab area.

## Dashboard Review

Owned by: [Features/Dashboard.md](Features/Dashboard.md)

1. Open Overview tab.
2. Load metrics for active Vault and selected period.
3. Display income, expenses, averages, saved amount, saving efficiency, and category charts.
4. User changes month/period.
5. Dashboard reloads with new date range.

## Category Management

Owned by: [Features/Categories.md](Features/Categories.md)

1. Open Categories tab.
2. List active Vault categories.
3. Add or edit category.
4. Validate non-empty name.
5. Enforce uniqueness in use case.
6. Refresh list.

## Operation Management

Owned by: [Features/Operations.md](Features/Operations.md)

1. Open Operations tab.
2. List selected month operations grouped by day.
3. Add, edit, view detail, or delete operation.
4. Save validates category and parseable amount.
5. List refreshes.

## Reimbursement Management

Owned by: [Features/Reimbursements.md](Features/Reimbursements.md)

1. Create or edit an expense.
2. Enable reimbursement.
3. Add reimbursement rows.
4. Save operation.
5. Persist reimbursements.
6. If received and cross-Vault, create linked income operation in destination Vault.

## CSV Import and Export

Owned by: [Features/CSV-Import-Export.md](Features/CSV-Import-Export.md)

Import starts from Create Vault. Export starts from Vault management.

## Settings and Security

Owned by: [Features/Settings-Security.md](Features/Settings-Security.md)

Settings owns Vault management, security, About placeholder, and Delete All Data.

## OCR and Assistant

Owned by: [Features/OCR-and-Finance-Assistant.md](Features/OCR-and-Finance-Assistant.md)

OCR pre-fills operation entry. Assistant entry is available from dashboard when supported.
