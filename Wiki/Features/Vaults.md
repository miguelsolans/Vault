# Vaults

## Feature Summary

A Vault is the top-level finance container. It owns operations and categories, has one currency, stores an initial deposit, and can be selected as the favorite Vault for app startup.

## Confirmed Behavior

- Vaults are persisted in Core Data entity `Vault`.
- `VaultRepository.create` requires an existing `Currency` matching `currencyCode`.
- `CreateVaultUseCase` ensures EUR exists before creating a Vault.
- New Vaults are created with default categories.
- Only the first created Vault is automatically stored as favorite.
- Existing Vaults can be listed, selected, edited, favorited, deleted, and exported.
- Deleting a Vault cascades to its operations and categories through the Core Data model.
- Current balance is computed dynamically from initial deposit, operations, and received same-vault reimbursements.

## Inferred Behavior

- Currency selection is not currently productized. Creation and editing pass `"EUR"`.
- Initial deposit is a starting balance, not an operation. It has no date, category, or audit history.
- Multiple Vaults are intended, but app startup always uses one favorite Vault.

## Unknown Behavior

- Whether Vault names must be unique.
- Whether initial deposit can be negative.
- Whether deleting the favorite Vault should choose a new favorite, prompt the user, or return to onboarding.
- Whether users should be prevented from deleting the last Vault from the Vault list.

## Primary Flow

1. User opens Create Vault.
2. User enters required name.
3. User optionally enables initial deposit and enters an amount.
4. User optionally enables CSV import and selects a CSV file.
5. App validates name, deposit parseability, and selected CSV when import is on.
6. `CreateVaultUseCase` creates EUR if missing.
7. Vault is created.
8. Default categories are populated.
9. If this is the first Vault, its ID becomes `favoriteVault`.
10. If import file exists, user goes to CSV import mapping. Otherwise user enters the private area.

## Default Categories

Confirmed in `CreateVaultUseCase`.

Expense:

- Drinks & Food
- Entertainment
- Vehicle
- Subscriptions
- Miscellaneous

Income:

- Bonus
- Salary
- Reimbursement

## Screens

- Create/edit Vault: `Features/Vault/Create/*`
- List/manage Vaults: `Features/Vault/List/*`
- Vault selector entry from dashboard: `Features/Dashboard/Coordinator/DashboardCoordinator.swift`
- Settings entry to Vault management: `Features/Settings/List/Coordinator/SettingsCoordinator.swift`

## Business Rules

- Vault name is required at UI validation level.
- Initial deposit must parse as a localized decimal/currency amount when provided.
- CSV file is required only when import toggle is on.
- First Vault becomes favorite.
- Favorite Vault selection is stored in UserDefaults.
- Vault currency is currently EUR.

## Calculations

`Vault.currentBalance`:

```text
initialDeposit
+ sum(income operation amounts)
- sum(expense operation amounts)
+ sum(received reimbursements where sourceVault == destinationVault == this Vault)
```

Cross-vault received reimbursements are represented as income operations in the destination Vault and are therefore counted by normal operation balance.

## Edge Cases

- Empty name: UI shows required-name feedback and does not save.
- Invalid deposit string: UI shows invalid-amount feedback and does not save.
- Import toggle on with no file: UI shows file-required feedback and does not save.
- Repository errors during create/edit are swallowed by placeholder error handlers; no user-facing error is confirmed.
- Deleting a Vault that is favorite does not explicitly clear or reassign `favoriteVault`.

## Architecture Notes

- Creation/editing flows use `CreateVaultViewModel` with create/edit use cases.
- Listing and management use `ListVaultViewModel`.
- Persistence is through `VaultRepository`.
- First-Vault favorite selection is implemented in `CreateVaultUseCase`, not the UI.

## Code Ownership

- Use cases: `Core/Domain/UseCases/Vault/*`
- Repository: `Core/Data/Repository/Vault/VaultRepository.swift`
- Balance formula: `Core/Data/Repository/Operation+CoreDataHelpers.swift`
- UI: `Features/Vault/Create/*`, `Features/Vault/List/*`

## Decision Blocks

> **Decision Block: VAULT-001 - Vault Name Uniqueness**
>
> Status: Unknown
>
> Code can fetch by case-insensitive name, but create/edit does not enforce unique Vault names. Decide whether duplicate Vault names are allowed.

> **Decision Block: VAULT-002 - Favorite Vault Deletion**
>
> Status: Unknown
>
> Deleting a favorite Vault leaves a stale `favoriteVault` value until startup falls back to onboarding. Decide whether deletion should clear favorite, select another Vault, or block deletion.

> **Decision Block: VAULT-003 - Currency Strategy**
>
> Status: Unknown
>
> Code creates and uses EUR. Decide whether Vault currency is fixed for MVP or whether users can select currencies.
