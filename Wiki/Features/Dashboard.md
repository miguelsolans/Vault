# Dashboard

## Feature Summary

Dashboard summarizes a selected Vault for a selected period. It shows total income, total expense, averages, saved amount, saving efficiency, and category charts.

## Confirmed Behavior

- Dashboard is the Overview tab in the private tab area.
- Dashboard receives the active `VaultDTO` from the app/private coordinator.
- Data is loaded through `DashboardUseCase`.
- The view model supports monthly and yearly periods.
- Monthly period uses the current month start/end.
- Yearly period uses the current year start/end.
- Month selector changes the filter to the selected month.
- `hasAny` checks whether any operation exists in the selected date range.
- Income category chart includes all income categories returned by grouped operation totals.
- Expense category chart includes only expense categories where `visibleInPlot == true`.
- Chat/finance assistant button availability depends on `FoundationModelAvailability.isSupported`.

## Inferred Behavior

- The old wiki statement that dashboard is current civil year only is outdated. Code supports current year and selected month filters.
- Averages are average operation amounts, not monthly averages.
- Saving efficiency is saved divided by spent, not saved divided by income.

## Unknown Behavior

- How saving efficiency should be displayed as a user-facing value: ratio, percent, currency-like value, or special state.
- What empty dashboard UI should show.
- Whether hidden expense categories should be grouped as "Other" instead of excluded from the expense chart.
- Whether dashboard should support historical years beyond selecting months through the current month selector.
- Whether the primary expense summary should show gross cash expenses or net expenses after received reimbursements.

## Primary Flow

1. User opens Overview tab.
2. Dashboard view model builds a `DashboardRequest` with Vault ID and current filter.
3. `DashboardUseCase` fetches totals, averages, reimbursements, and category totals.
4. View model builds summary cards and charts.
5. User changes period or month.
6. View model reloads data with updated date range.

## Screens

- Dashboard screen: `Features/Dashboard/View/DashboardViewController.swift`
- Dashboard view model: `Features/Dashboard/ViewModel/DashboardViewModel.swift`
- Chart UI: `Features/Chart/*`
- Shared summary UI: `Shared/ProjectUI/Summary View/*`
- Month selector: `Shared/ProjectUI/MonthSelectorView/*`

## Business Rules

- Dashboard data is scoped to one Vault.
- Date filtering is inclusive for both start and end date in repository predicates.
- `totalIncome` and `totalSpent` are all-time totals for the Vault.
- `income`, `spent`, `averageIncome`, and `averageSpent` are period-scoped.
- `totalInVault` includes initial deposit and received same-vault reimbursements.
- Expense category chart filters by `visibleInPlot == true`.
- Income category chart does not apply `visibleInPlot` filtering.

## Calculations

All formulas are confirmed in `DashboardUseCase`, `OperationRepository+Metrics`, and `OperationMetrics`.

```text
totalIncome = sum(all income operation amounts in Vault)
totalSpent = sum(all expense operation amounts in Vault)
income = sum(income operation amounts in selected date range)
spent = sum(expense operation amounts in selected date range)
averageIncome = average(income operation amount in selected date range)
averageSpent = average(expense operation amount in selected date range)
saved = income - spent
totalSaved = totalIncome - totalSpent
savingEfficiency = spent == 0 ? saved : saved / spent
totalSavingEfficiency = totalSpent == 0 ? totalSaved : totalSaved / totalSpent
totalInVault = ((initialDeposit + totalIncome) - totalSpent) + receivedSameVaultReimbursements
```

## Proposed Metrics Contract

Status: proposed target for reimbursement-aware dashboard refactor. Detailed formulas live in [8-Calculations and Formulas](../8-Calculations%20and%20formulas.md).

Dashboard should expose separate metric groups:

```swift
struct DashboardMetrics {
    let period: MetricsPeriod
    let balance: BalanceMetrics
    let cashFlow: CashFlowMetrics
    let netSpending: NetSpendingMetrics
    let reimbursements: ReimbursementMetrics
    let categories: CategoryMetrics
}
```

The purpose of each group:

- `balance`: current Vault balance, including initial deposit and same-vault received reimbursement adjustment.
- `cashFlow`: actual money movement in the selected Vault during the period.
- `netSpending`: final cost after received reimbursements attached to expense operations.
- `reimbursements`: reimbursement pipeline totals by status and same-vault/cross-vault split.
- `categories`: grouped income, gross expense, and net expense chart data.

Recommended UI mapping:

- Header subtitle: `balance.currentBalance`.
- Income summary card: `cashFlow.income`.
- Expense summary card: choose explicitly between `cashFlow.expenses` and `netSpending.netExpenses`.
- Savings/statistics card: `netSpending.savings`.
- Income chart: `categories.income`.
- Expense chart: choose explicitly between `categories.grossExpenses` and `categories.netExpenses`.
- Reimbursement cards, if added: `reimbursements.expected`, `reimbursements.received`, and `reimbursements.cancelled`.

Refactor rule: a metric name must reveal whether it is cash-based or net-cost-based. New dashboard code should avoid generic names like `spent` unless scoped by a parent such as `cashFlow.expenses`.

## Edge Cases

- No operations in range: repository sums and averages return `0.0`; `isVaultEmpty` becomes true.
- Spent is zero: `savingEfficiency` returns `saved`.
- Total spent is zero: `totalSavingEfficiency` returns `totalSaved`.
- Categories with nil color may crash when force-cast in category totals; model allows optional color, DTO assumes non-nil.
- Category total sorting parameter is accepted, but repository currently sorts descending whenever the parameter exists.

## Architecture Notes

- `DashboardViewModel` owns filter state and builds UI summary/chart view models.
- `DashboardUseCase` orchestrates repository metric queries.
- Aggregations are computed in Core Data fetch expressions inside `OperationRepository+Metrics`.
- Assistant availability is checked in the view model through `FoundationModelAvailability`.

## Code Ownership

- Use case and formulas: `Core/Domain/UseCases/Dashboard/DashboardUseCase.swift`
- Repository metrics: `Core/Data/Repository/Operation/OperationRepository+Metrics.swift`
- View model: `Features/Dashboard/ViewModel/DashboardViewModel.swift`
- Date helpers: `Features/Dashboard/ViewModel/DashboardViewModel.swift`

## Decision Blocks

> **Decision Block: DASH-001 - Saving Efficiency Definition**
>
> Status: Unknown
>
> Code defines `savingEfficiency = saved / spent`, with `spent == 0` fallback to `saved`. Decide whether this is the intended financial metric. Common alternatives include `saved / income` or `saved / (income + initialDeposit)`.

> **Decision Block: DASH-002 - Empty Dashboard State**
>
> Status: Unknown
>
> Code exposes `isVaultEmpty`, but the wiki does not define the empty UI, call to action, or chart fallback. Decide the empty state per period.

> **Decision Block: DASH-003 - Hidden Categories**
>
> Status: Unknown
>
> Expense chart excludes categories not visible in plot. Decide whether hidden totals should disappear, remain in totals only, or appear as an "Other" group.

> **Decision Block: DASH-004 - Gross vs Net Expense Display**
>
> Status: Unknown
>
> Reimbursements create two valid expense numbers: gross cash expenses and net expenses after received reimbursements. Decide which one should drive the dashboard's primary expense summary and expense chart.
