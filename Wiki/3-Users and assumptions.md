# 3. Users and Assumptions

## Primary User

Confirmed: A single iOS user managing personal finances locally.

## Confirmed Assumptions

- User manually creates Vaults, categories, and operations.
- User may import historical operations from CSV during Vault creation.
- User expects offline/local persistence through Core Data.
- User can manage more than one Vault.
- User may protect app startup with a local PIN.

## Inferred Assumptions

- The user understands income, expense, category, and balance concepts.
- The user wants lightweight financial insight rather than accounting-grade ledgers.
- CSV export is useful for backup or external analysis.
- AI/OCR features are optional accelerators.

## Unknown Assumptions Requiring Decisions

- Whether the target user needs budgeting workflows beyond stored monthly category budget fields.
- Whether the user needs historical year navigation beyond current monthly/yearly filters.
- Whether reimbursements are mostly same-Vault personal refunds or cross-Vault transfers.
- Whether the user expects strict auditability for initial deposit and generated reimbursement income operations.
