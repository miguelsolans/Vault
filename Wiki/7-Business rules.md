# 7. Business Rules

This page lists shared rules only. Feature pages own detailed confirmed/inferred/unknown behavior.

## Vault Rules

Confirmed:

- Vault name is required in create/edit UI.
- Initial deposit is optional and defaults to `0.0` when empty.
- Initial deposit is not stored as an operation.
- First created Vault becomes favorite.
- Vault currency is currently EUR.
- Creating a Vault creates default income and expense categories.

Unknown:

- Vault name uniqueness.
- Negative initial deposit policy.
- Favorite Vault deletion policy.

## Category Rules

Confirmed:

- Category belongs to a Vault.
- Category type is income or expense.
- Category name is required in UI.
- Category name is trimmed before storage.
- Add/edit use cases enforce uniqueness by name within Vault.
- Category list marks categories with operations as not deletable.

Unknown:

- Whether uniqueness should be by Vault/name or Vault/name/type.
- Whether delete protection belongs in UI only or domain layer.
- Budget behavior.

## Operation Rules

Confirmed:

- Operation belongs to a Vault.
- Operation belongs to a Category.
- Operation type is income or expense.
- UI requires category matching operation type.
- UI requires amount to be parseable.
- Date defaults to today and is required.
- Operation deletion deletes related reimbursements first.

Unknown:

- Positive-only operation amount.
- Future-date policy.
- Required title/description policy.
- Duplicate detection policy.

## Reimbursement Rules

Confirmed:

- Reimbursements are only exposed for expenses.
- Reimbursement amount must be greater than zero at repository level.
- Received cross-vault reimbursement creates linked income operation.
- Status transition away from received deletes linked income operation.
- Deleting reimbursement deletes linked income operation.

Unknown:

- Maximum reimbursement amount.
- Reimbursement date model.
- Direct deletion/edit policy for linked income operations.

## Dashboard Rules

Confirmed:

- Dashboard is scoped to selected Vault.
- Dashboard supports monthly and yearly filters.
- Income category totals include all income categories with matching operations.
- Expense category chart includes only `visibleInPlot == true` categories.
- Averages are average operation amounts.

Unknown:

- User-facing saving efficiency definition and display.
- Empty state.
- Hidden category presentation.

## Import/Export Rules

Confirmed:

- Import is optional during Vault creation.
- Import screen requires five mapped fields.
- CSV reader uses UTF-8, semicolon separator, and header row in current flow.
- Export requires at least one operation.

Unknown:

- Canonical CSV implementation.
- Whether arbitrary mapped headers or fixed schema is the supported contract.
- Invalid row policy.
