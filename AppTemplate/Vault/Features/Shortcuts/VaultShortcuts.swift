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
            AppShortcut(
                intent: AddExpenseIntent(),
                phrases: [
                    "Add expense to \(.applicationName)"
                ],
                shortTitle: "Add expense",
                systemImageName: "arrow.up.circle"
            ),
            AppShortcut(
                intent: AddIncomeIntent(),
                phrases: [
                    "Add income to \(.applicationName)"
                ],
                shortTitle: "Add income",
                systemImageName: "arrow.down.circle"
            ),
            AppShortcut(
                intent: ExpectedReimbursementsIntent(),
                phrases: [
                    "Am I expecting any reimbursement in \(.applicationName)",
                    "Do I have any pending reimbursement in \(.applicationName)",
                    "Am I expecting any money in \(.applicationName)"
                ],
                shortTitle: "Expected reimbursement",
                systemImageName: "wallet.bifold"
            ),
            AppShortcut(
                intent: CheckBalanceIntent(),
                phrases: [
                    "What's my current balance in \(.applicationName)",
                    "How much money do I have in \(.applicationName)",
                    "Check my balance in \(.applicationName)"
                ],
                shortTitle: "Check balance",
                systemImageName: "wallet.bifold"
            ),
            AppShortcut(
                intent: MonthlySavedIntent(),
                phrases: [
                    "How much did I save this month in \(.applicationName)"
                ],
                shortTitle: "Monthly saved",
                systemImageName: "wallet.bifold"
            ),
            AppShortcut(
                intent: MonthlySpentIntent(),
                phrases: [
                    "How much did I spend this month in \(.applicationName)"
                ],
                shortTitle: "Monthly spent",
                systemImageName: "wallet.bifold"
            ),
        ]
    }
}
