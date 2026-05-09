# 2. Core Concepts

## Vault

Confirmed: A Vault is the user's financial container. It owns operations and categories, has one currency, and stores an initial deposit.

See: [Features/Vaults.md](Features/Vaults.md)

## Operation

Confirmed: An operation is a money record inside a Vault. It is either income or expense and has an amount, date, title, optional notes, and category.

See: [Features/Operations.md](Features/Operations.md)

## Category

Confirmed: A category classifies operations. Categories belong to a Vault and have an operation type.

Current code note: uniqueness is enforced by Vault/name, not by Vault/name/type.

See: [Features/Categories.md](Features/Categories.md)

## Reimbursement

Confirmed: A reimbursement belongs to an original expense operation and tracks expected/received/cancelled money back. Cross-vault received reimbursements generate linked income operations in the destination Vault.

See: [Features/Reimbursements.md](Features/Reimbursements.md)

## Dashboard

Confirmed: Dashboard computes period-scoped summaries and category charts for the active Vault. Code supports monthly and yearly period filters.

See: [Features/Dashboard.md](Features/Dashboard.md)

## Favorite Vault

Confirmed: The favorite Vault ID is stored in UserDefaults and drives app startup routing.

See: [Features/App-Start-Onboarding-Login.md](Features/App-Start-Onboarding-Login.md)

## Local Security

Confirmed: PIN authentication uses UserDefaults flags plus a Keychain-stored PIN. It gates app launch routing when enabled.

See: [Features/Settings-Security.md](Features/Settings-Security.md)
