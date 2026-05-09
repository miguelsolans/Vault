//
//  AddOperationIntent.swift
//  Vault
//
//  Created by Miguel Solans on 02/04/2026.
//

import AppIntents
import VaultCore

// MARK: - Shortcuts Provider
struct VaultShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: AddExpenseIntent(),
                phrases: [
                    // "Add expense of \(.parameter(\.$amount)) to \(.applicationName)"
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
            )
        ]
    }
}
