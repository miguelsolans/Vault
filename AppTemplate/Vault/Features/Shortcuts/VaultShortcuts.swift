//
//  AddOperationIntent.swift
//  Vault
//
//  Created by Miguel Solans on 02/04/2026.
//

import AppIntents
import VaultCore

struct VaultShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            /* Add Expense */
            AppShortcut(
                intent: AddExpenseIntent(),
                phrases: [
                    "Add an expense to \(.applicationName)",
                    "Register an expense on \(.applicationName)"
                ],
                shortTitle: LocalizedStringResource("shortcut.addExpense.shortTitle"),
                systemImageName: "arrow.up.circle"
            ),
            /* Add Income */
            AppShortcut(
                intent: AddIncomeIntent(),
                phrases: [
                    "Add an income to \(.applicationName)",
                    "Register an income on \(.applicationName)"
                ],
                shortTitle: LocalizedStringResource("shortcut.addIncome.shortTitle"),
                systemImageName: "arrow.down.circle"
            ),
            /* Pending Reimbursements */
            AppShortcut(
                intent: ExpectedReimbursementsIntent(),
                phrases: [
                    "Am I expecting any reimbursement in \(.applicationName)",
                    "Do I have any pending reimbursement in \(.applicationName)",
                    "Am I expecting any money in \(.applicationName)"
                ],
                shortTitle: LocalizedStringResource("shortcut.pendingReimbursements.shortTitle"),
                systemImageName: "wallet.bifold"
            ),
            /* Balance */
            AppShortcut(
                intent: CheckBalanceIntent(),
                phrases: [
                    "What's my current balance in \(.applicationName)",
                    "How much money do I have in \(.applicationName)",
                    "Check my balance in \(.applicationName)"
                ],
                shortTitle: LocalizedStringResource("shortcut.checkBalance.shortTitle"),
                systemImageName: "wallet.bifold"
            ),
            /* MonthlySaved */
            AppShortcut(
                intent: MonthlySavedIntent(),
                phrases: [
                    "How much did I save this month in \(.applicationName)"
                ],
                shortTitle: LocalizedStringResource("shortcut.savedThisMonth.shortTitle"),
                systemImageName: "wallet.bifold"
            ),
            /* MonthlySaved */
            AppShortcut(
                intent: MonthlySpentIntent(),
                phrases: [
                    "How much did I spend this month in \(.applicationName)"
                ],
                shortTitle: LocalizedStringResource("shortcut.spentThisMonth.shortTitle"),
                systemImageName: "wallet.bifold"
            ),
        ]
    }
}
