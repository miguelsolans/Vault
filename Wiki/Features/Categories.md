# Categories

## Feature Summary

Categories classify operations by type and can control dashboard chart visibility. Expense categories can optionally carry a monthly budget value, although budget calculations are not currently wired into dashboard rules.

## Confirmed Behavior

- Categories belong to one Vault.
- Categories use `OperationType` as their type: income or expense.
- Category list shows all categories for the active Vault.
- Category add/edit validates name is non-empty.
- Add/edit use cases enforce case-insensitive name uniqueness within a Vault.
- Category operation type cannot be changed from the edit UI.
- Category cells expose `canDelete = !category.hasOperations`.
- Expense categories can show a budget toggle/input.
- Income categories hide/disable budget behavior.
- `visibleInPlot` controls inclusion in expense dashboard category chart.

## Inferred Behavior

- Category names are unique per Vault, not per type, because repository lookup ignores type in `get(name:type:in:)`.
- The wiki's older "unique within same type" rule is not code-aligned.
- UI prevents deletion for categories with operations, but the delete use case can delete any category if called.

## Unknown Behavior

- Whether category uniqueness should be per Vault or per Vault plus type.
- Whether deleting categories with operations should be blocked at domain level.
- Whether category budgets should affect dashboard, operation list, alerts, or only future UI.
- Whether `visibleInPlot` should apply to income categories.

## Primary Flow

1. User opens Categories tab.
2. `ListCategoriesUseCase` loads categories for active Vault.
3. User taps add.
4. User selects expense or income.
5. User enters required category name.
6. User optionally sets emoji, color, plot visibility, and expense budget.
7. Save validates non-empty name.
8. Use case enforces uniqueness.
9. Category is created or edited and list refreshes.

## Screens

- List categories: `Features/Categories/List/*`
- Add/edit category: `Features/Categories/Add/*`
- Category cell: `Shared/ProjectUI/Category TableViewCell/*`

## Business Rules

- Name is required.
- Name is trimmed before storage.
- Emoji is optional.
- Color is optional in repository API but DTO and dashboard currently assume non-nil.
- Visible-in-plot is optional business meaning outside dashboard expense chart.
- Expense budget can be set; income budget is hidden/disabled in UI.
- Adding a duplicate category name in the same Vault throws `CategoryError.categoryAlreadyExists`.
- Editing a category to another category's name throws `CategoryError.categoryAlreadyExists`.

## Calculations

No feature-specific formulas are confirmed. Category budgets are stored but not used in confirmed calculations.

## Edge Cases

- Empty name: UI blocks save.
- Duplicate name: use case throws; current UI does not present the error.
- Category with operations: list cell says it cannot delete, but domain delete is not protected.
- Deleting a category through use case nullifies relationships in Core Data and can create orphaned operations.
- Color nil can crash DTO/category-total conversion.

## Architecture Notes

- Category list and add/edit screens use feature ViewModels and coordinators.
- Category persistence goes through `CategoryRepository`.
- Uniqueness is enforced in add/edit use cases.
- Delete availability is currently computed for UI from `CategoryDTO.hasOperations`.

## Code Ownership

- Use cases: `Core/Domain/UseCases/Categories/*`
- Repository: `Core/Data/Repository/Category/CategoryRepository.swift`
- DTO: `Core/Domain/DTO/CategoryDTO.swift`
- UI: `Features/Categories/*`

## Decision Blocks

> **Decision Block: CAT-001 - Category Uniqueness Scope**
>
> Status: Unknown
>
> Product doc says unique within same type. Code currently enforces uniqueness by name and Vault, regardless of type. Decide the intended rule and align repository predicates.

> **Decision Block: CAT-002 - Delete Protection**
>
> Status: Unknown
>
> UI hides delete for categories with operations, but the domain use case does not enforce this. Decide whether deletion must be blocked in `DeleteCategoryUseCase`.

> **Decision Block: CAT-003 - Monthly Budgets**
>
> Status: Unknown
>
> Model and add/edit UI support monthly budgets for expense categories, but dashboard/list calculations do not use them. Decide MVP behavior.
