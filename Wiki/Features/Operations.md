# Operations

## Feature Summary

Operations are income or expense records inside a Vault. They are listed by month, grouped by day, can be created, edited, deleted, imported, exported, and optionally linked to reimbursements.

## Confirmed Behavior

- Operation types are `income` and `expense`.
- Add/edit forms display operation type in order: expense, income.
- Category options are filtered to the selected operation type.
- Operation list defaults to the current month and groups operations by day descending.
- Operation list section amount uses each operation's `netAmount`.
- Add-from-camera is available only when Foundation Models are supported.
- Operation detail can be presented from the list.
- Deleting an operation deletes all reimbursements for that operation before deleting the operation.

## Inferred Behavior

- Amount must be parseable, but positive-only is not enforced for operations.
- Description/title is optional in the UI, but `OperationDTO` assumes title is non-nil.
- Future dates are allowed because the date picker/view model has no max-date rule.

## Unknown Behavior

- Whether operation amount can be zero or negative.
- Whether operation title should be required.
- Whether editing an operation with reimbursements should allow changing type/category/amount.
- Whether imported operations should allow duplicate detection.

## Primary Flow

1. User opens Operations tab.
2. View model selects the current month.
3. `ListOperationsByDayUseCase` loads operations between month start and month end.
4. Operations are grouped by calendar day and sorted newest day first.
5. User taps add, optionally preselecting income or expense.
6. User selects operation type, category, amount, optional description, and date.
7. If expense, user can enable reimbursements and add reimbursement rows.
8. Save validates category and amount parseability.
9. `AddOperationsUseCase` creates the operation.
10. If reimbursements are enabled, reimbursement requests are created for the new operation.

## Screens

- List operations: `Features/Operations/List/*`
- Add/edit operation: `Features/Operations/Add/*`
- Operation detail: `Features/Operations/Detail/*`
- OCR entry: `Features/OCR/*`
- Reimbursement child flow: `Features/Reimbursement/Add/*`

## Business Rules

- Operation belongs to one Vault.
- Operation belongs to one Category.
- UI requires a category matching the selected operation type.
- UI requires amount to be non-empty and parseable.
- Date is required and defaults to current date.
- Reimbursement controls are visible only for expenses.
- Changing operation type resets reimbursement toggle and reloads category options.
- When deleting an operation, its reimbursements are deleted first.

## Calculations

`OperationDTO.totalReimbursed`:

```text
sum(reimbursement.amount where reimbursement.isSameVault && status == received)
```

`OperationDTO.netAmount`:

```text
amount - totalReimbursed
```

Operation list section total:

```text
sum(operation.netAmount for operations in grouped day)
```

## Edge Cases

- No categories for selected type: category picker is disabled and save cannot pass category validation.
- Invalid amount string: save is blocked with invalid-amount feedback.
- Zero or negative amount: currently parseable and not blocked by operation validation.
- Repository errors in add/edit/list/delete are mostly handled by placeholders or printed; user-facing error behavior is not defined.
- Category can be force-unwrapped in `OperationDTO`; orphaned operations can crash when converted to DTO.

## Architecture Notes

- Operations tab is coordinated by `OperationsCoordinator`.
- List, add/edit, detail, OCR, and reimbursement entry are separate presentation flows.
- Add/edit ViewModel performs UI validation, then delegates persistence to use cases.
- Listing uses `ListOperationsByDayUseCase` and repository grouping.

## Code Ownership

- Use cases: `Core/Domain/UseCases/Operations/*`
- Repository: `Core/Data/Repository/Operation/*`
- DTO: `Core/Domain/DTO/OperationDTO.swift`
- View models: `Features/Operations/List/ViewModel/ListOperationsViewModel.swift`, `Features/Operations/Add/ViewModel/AddOperationViewModel.swift`

## Decision Blocks

> **Decision Block: OPS-001 - Amount Bounds**
>
> Status: Unknown
>
> UI validates parseability only. Decide whether operation amounts must be greater than zero and whether imported negative values represent expenses, refunds, or invalid rows.

> **Decision Block: OPS-002 - Operation Title Requirement**
>
> Status: Unknown
>
> UI marks description as optional, but DTO force unwraps `operation.title`. Decide whether title is required or DTO/model should handle nil.

> **Decision Block: OPS-003 - Editing Reimbursed Operations**
>
> Status: Unknown
>
> Code allows editing operation amount/type/category while reimbursements may exist. Decide whether edits should be blocked, recalculate linked income operations, or show warnings.
