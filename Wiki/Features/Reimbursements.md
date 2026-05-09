# Reimbursements

## Feature Summary

Reimbursements model money expected back from an expense. They can be expected, received, or cancelled. Same-vault reimbursements adjust the source operation's net amount and Vault balance. Cross-vault received reimbursements create an income operation in the destination Vault.

## Confirmed Behavior

- Reimbursements belong to an original expense operation.
- Reimbursements have source Vault, destination Vault, destination income category, amount, notes, and status.
- Reimbursement status values are expected, received, and cancelled.
- Reimbursement amount must be greater than zero in `ReimbursementRepository`.
- Reimbursement controls are only visible for expense operations.
- Received cross-vault reimbursement creates a linked income operation in the destination Vault.
- Expected or cancelled cross-vault reimbursement does not create income.
- Changing a reimbursement away from received deletes the linked income operation.
- Deleting a reimbursement deletes its linked income operation if one exists.
- Deleting an operation deletes all reimbursements associated with it.

## Inferred Behavior

- Same-vault received reimbursements do not create income operations; balance adds them back manually.
- Operation list net amount only subtracts same-vault received reimbursements.
- Cross-vault reimbursements affect destination Vault through generated income operations, not source operation net amount.

## Unknown Behavior

- Whether reimbursement total can exceed the original expense.
- Whether multiple reimbursements are allowed for one operation.
- Whether cross-vault reimbursement income date should be received date, creation date, or user-selected date.
- Whether same-vault received reimbursements should appear in operation history as income-like records.

## Primary Flow

1. User creates or edits an expense operation.
2. User enables reimbursement.
3. User adds one or more reimbursement entries.
4. User selects reimbursement amount, status, deposit Vault, and deposit income category.
5. Operation is saved first.
6. Reimbursement use case creates reimbursement rows for that operation.
7. If a reimbursement is received and destination Vault differs from source Vault, app creates a linked income operation.

## Screens

- Reimbursement entry: `Features/Reimbursement/Add/*`
- Reimbursement rows in add/edit operation: `Shared/ProjectUI/Reimbursement TableViewCell/*`
- Operation add/edit host: `Features/Operations/Add/*`

## Business Rules

- Reimbursement amount must be greater than zero at repository level.
- Destination category must be an income category from the selected destination Vault in the add reimbursement UI.
- Reimbursements are persisted only after the parent operation exists.
- Linked income operation has type income, amount equal to reimbursement amount, destination Vault, selected income category, and `reimbursementSource`.
- Status transition to non-received deletes linked income operation.
- Status transition to received creates linked income operation when missing and destination differs from source.

## Calculations

Same-vault reimbursement effect on operation display:

```text
operation.netAmount = operation.amount - sum(received same-vault reimbursements)
```

Same-vault reimbursement effect on Vault balance:

```text
currentBalance adds sum(received reimbursements where sourceVault == destinationVault == Vault)
```

Cross-vault reimbursement effect:

```text
destinationVault balance increases through linked income operation
source operation netAmount is unchanged
```

## Edge Cases

- Add reimbursement UI validation methods currently return true; invalid/empty fields can produce amount `0.0` and later repository errors.
- `destinationCategory` is force-unwrapped when creating reimbursement requests from the operation form.
- Cross-vault received reimbursement uses `Date()` for generated income operation, not a user-selected settlement date.
- Deleting linked income operation directly from operations list may leave reimbursement pointing to a deleted or nil income operation depending Core Data behavior.

## Architecture Notes

- Reimbursement entry is a child flow launched from Add Operation.
- Temporary reimbursement DTOs are collected before the parent operation is persisted.
- `AddReimbursementUseCase` creates persisted reimbursements after the operation exists.
- Status transitions are managed by `UpdateReimbursementStatusUseCase`.
- Reimbursement and linked income deletion is managed by reimbursement/delete use cases.

## Code Ownership

- Use cases: `Core/Domain/UseCases/Reimbursement/*`
- Repository: `Core/Data/Repository/Reimbursement/ReimbursementRepository.swift`
- DTO: `Core/Domain/DTO/OperationDTO.swift`
- Balance logic: `Core/Data/Repository/Operation+CoreDataHelpers.swift`
- UI: `Features/Reimbursement/Add/*`, `Features/Operations/Add/*`

## Decision Blocks

> **Decision Block: REIM-001 - Maximum Reimbursement Amount**
>
> Status: Unknown
>
> Code allows multiple reimbursements and does not cap total reimbursement against the expense amount. Decide whether over-reimbursement is valid.

> **Decision Block: REIM-002 - Reimbursement Date**
>
> Status: Unknown
>
> Generated income operations use `Date()`. Decide whether reimbursement needs expected date, received date, and/or settlement date.

> **Decision Block: REIM-003 - Linked Income Deletion**
>
> Status: Unknown
>
> Direct deletion of a linked reimbursement income operation is not documented as a user flow. Decide whether it should be blocked, cascade back to reimbursement status, or detach safely.
