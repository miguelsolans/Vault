# 8. Calculations and Formulas

This page records formulas confirmed in code. Product disagreements should become Decision Blocks in the owning feature page before code changes.

## Vault Current Balance

Source: `Vault.currentBalance` in `Core/Data/Repository/Operation+CoreDataHelpers.swift`

```text
currentBalance =
  initialDeposit
  + sum(income operation amounts)
  - sum(expense operation amounts)
  + sum(received same-vault reimbursement amounts)
```

Same-vault reimbursement means:

```text
reimbursement.status == received
and reimbursement.sourceVault == Vault
and reimbursement.destinationVault == Vault
```

## Dashboard Totals

Source: `DashboardUseCase`, `OperationRepository+Metrics`

```text
totalIncome = sum(all income operation amounts in Vault)
totalSpent = sum(all expense operation amounts in Vault)
income = sum(income operation amounts in selected date range)
spent = sum(expense operation amounts in selected date range)
```

## Proposed Dashboard Metrics Refactor

Status: proposed target for the reimbursement-aware metrics refactor.

The current flat `OperationMetrics` mixes cash movement, net spending, and reimbursement state. The refactor should separate those concepts so each value answers one question and the UI can choose the right value intentionally.

### Vocabulary

```text
cash flow = money that physically enters or leaves a Vault
gross expense = original expense operation amount before reimbursements
received reimbursement = reimbursement with status == received
net expense = gross expense minus received reimbursements for that expense
same-vault reimbursement = sourceVault == destinationVault
cross-vault reimbursement = sourceVault != destinationVault
```

### Proposed Output Shape

```swift
struct DashboardMetrics {
    let period: MetricsPeriod
    let balance: BalanceMetrics
    let cashFlow: CashFlowMetrics
    let netSpending: NetSpendingMetrics
    let reimbursements: ReimbursementMetrics
    let categories: CategoryMetrics
}

struct MetricsPeriod {
    let startDate: Date?
    let endDate: Date?
}

struct BalanceMetrics {
    let initialDeposit: Double
    let currentBalance: Double
}

struct CashFlowMetrics {
    let income: Double
    let expenses: Double
    let netCashFlow: Double
    let averageIncome: Double
    let averageExpense: Double
}

struct NetSpendingMetrics {
    let grossExpenses: Double
    let receivedReimbursements: Double
    let netExpenses: Double
    let savings: Double
    let savingEfficiency: Double
}

struct ReimbursementMetrics {
    let expected: Double
    let received: Double
    let cancelled: Double
    let sameVaultReceived: Double
    let crossVaultReceived: Double
}

struct CategoryMetrics {
    let income: [AmountPerCategory]
    let grossExpenses: [AmountPerCategory]
    let netExpenses: [AmountPerCategory]
}
```

### Proposed Formulas

Balance follows cash movement:

```text
currentBalance =
  initialDeposit
  + sum(income operation amounts)
  - sum(expense operation amounts)
  + sum(received same-vault reimbursement amounts)
```

Cash flow follows operation records:

```text
cashFlow.income = sum(income operation amounts in period)
cashFlow.expenses = sum(expense operation amounts in period)
cashFlow.netCashFlow = cashFlow.income - cashFlow.expenses
cashFlow.averageIncome = average(income operation amount in period)
cashFlow.averageExpense = average(expense operation amount in period)
```

Net spending follows the original expense's final cost:

```text
netSpending.grossExpenses = sum(expense operation amounts in period)
netSpending.receivedReimbursements =
  sum(received reimbursements for expense operations in period)
netSpending.netExpenses =
  netSpending.grossExpenses - netSpending.receivedReimbursements
netSpending.savings =
  cashFlow.income - netSpending.netExpenses
netSpending.savingEfficiency =
  netSpending.netExpenses == 0
    ? netSpending.savings
    : netSpending.savings / netSpending.netExpenses
```

Reimbursement state totals:

```text
reimbursements.expected = sum(expected reimbursement amounts)
reimbursements.received = sum(received reimbursement amounts)
reimbursements.cancelled = sum(cancelled reimbursement amounts)
reimbursements.sameVaultReceived =
  sum(received reimbursements where sourceVault == destinationVault)
reimbursements.crossVaultReceived =
  sum(received reimbursements where sourceVault != destinationVault)
```

Category metrics:

```text
categories.income =
  income operations grouped by income category

categories.grossExpenses =
  expense operations grouped by expense category

categories.netExpenses =
  expense operations grouped by expense category,
  reduced by received reimbursements attached to those expenses
```

### Period Semantics

Use different dates for different questions:

```text
cashFlow metrics use operation.date
netSpending metrics use original expense operation.date
reimbursement state metrics should declare their date basis before implementation
```

Recommended decision:

```text
netSpending.receivedReimbursements uses original expense date
cashFlow.income includes cross-vault reimbursement income on linked income operation date
```

This keeps "what happened to my vault balance" separate from "what did this period actually cost me".

### Naming Rules

- Use `grossExpenses` when reimbursements have not been subtracted.
- Use `netExpenses` when received reimbursements have been subtracted.
- Use `cashFlow` for vault movement.
- Use `netSpending` for final cost after reimbursements.
- Avoid ambiguous names like `spent` in new APIs.
- Keep all-time totals and period totals in separate fields or nested objects.

## Dashboard Averages

Source: `OperationRepository.averageAmount`

```text
averageIncome = average(amount of income operations in selected date range)
averageSpent = average(amount of expense operations in selected date range)
```

Confirmed correction: these are average operation amounts, not average per month.

## Saved Amount

Source: `OperationMetrics`

```text
saved = income - spent
totalSaved = totalIncome - totalSpent
```

## Saving Efficiency

Source: `OperationMetrics`

```text
savingEfficiency = spent == 0 ? saved : saved / spent
totalSavingEfficiency = totalSpent == 0 ? totalSaved : totalSaved / totalSpent
```

Product decision required: see `DASH-001` in [Features/Dashboard.md](Features/Dashboard.md).

## Total in Vault

Source: `OperationMetrics.totalInVault`

```text
totalInVault =
  ((initialDeposit + totalIncome) - totalSpent)
  + reimbursementsInSameDestination
```

`reimbursementsInSameDestination` is the sum of received reimbursements where source and destination are the same selected Vault.

## Operation Net Amount

Source: `OperationDTO`

```text
totalReimbursed =
  sum(received reimbursements where sourceVault == destinationVault)

netAmount = amount - totalReimbursed
```

Used by Operations list cells and day section totals.

## Category Totals

Source: `OperationRepository.totalAmountPerCategory`

```text
amountPerCategory =
  sum(operation.amount)
  grouped by category.id, category.name, category.color
  filtered by Vault, date range, and operation type
```

Dashboard usage:

- income categories: no visible-in-plot filter.
- expense categories: `visibleInPlot == true`.

## CSV Export Fields

Source: `ExportOperationsUseCase`

```text
Date = date formatted as "d MMMM yyyy"
Type = "Expense" or "Income"
Category = operation.category.name or "Unknown"
Description = operation.title or empty string
Amount = pt_PT currency-formatted amount
```
