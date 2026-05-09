# 9. Edge Cases

This page lists cross-feature edge cases. Feature-specific handling is documented in each feature page.

## Startup

- Missing favorite Vault: onboarding opens.
- Invalid favorite Vault UUID: onboarding opens.
- Favorite Vault deleted: startup cannot find it and opens onboarding.
- PIN required but Keychain PIN missing: login cannot succeed.

## Vaults

- Empty name: create/edit UI blocks save.
- Invalid deposit string: create/edit UI blocks save.
- Duplicate Vault name: not currently blocked.
- Delete last Vault: no explicit domain rule.
- Delete favorite Vault: no explicit favorite reassignment.

## Categories

- Empty name: UI blocks save.
- Duplicate name: domain use case throws, UI presentation undefined.
- Delete category with operations: UI marks as not deletable, domain use case still allows deletion if called.
- Nil category color/title relationships can crash DTO/dashboard conversion.

## Operations

- No categories for selected type: picker disabled; save cannot pass category validation.
- Invalid amount string: UI blocks save.
- Zero/negative amount: not currently blocked for operations.
- Future date: not currently blocked.
- Missing title/category due optional Core Data fields can crash DTO conversion.

## Reimbursements

- Zero reimbursement amount: repository throws invalid amount.
- Empty reimbursement form fields: add reimbursement UI validation currently returns true.
- Cross-vault received reimbursement creates linked income operation dated `Date()`.
- Status change away from received deletes linked income operation.
- Direct linked income operation deletion behavior is undefined.

## Dashboard

- No operations in selected period: sums/averages return zero; empty UI decision is open.
- `spent == 0`: saving efficiency returns saved amount.
- Hidden expense categories are excluded from expense chart.
- Category total sorting parameter is not fully honored.

## CSV

- Empty file: reader throws `emptyFile`.
- Wrong encoding: reader cannot read file.
- Row value count not matching header count: row is skipped.
- User field mapping is currently not honored by wired import use case.
- Unknown type defaults to expense in wired import use case.

## Security

- Wrong PIN has no lockout or visible error defined.
- Disabling PIN leaves stored Keychain PIN.
- Biometric row is disabled despite stored preference support.

## AI/OCR

- OCR parse failure has no user-facing handling.
- Receipt category mismatch causes save validation failure.
- Unsupported Foundation Models should hide/disable AI entry points.
