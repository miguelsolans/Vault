//
//  L10n+Shortcuts.swift
//  Vault
//
//  Created by Miguel Solans on 09/06/2026.
//

import Foundation

extension L10n.Shortcuts {
    
    static let noFavoriteVaultError = LocalizedStringResource("shortcuts.noFavoriteVault.error")
    
    enum AddExpense {
        static let resultSuccess = NSLocalizedString("shortcut.addExpense.resultSuccess", comment: "")
        static let resultError = LocalizedStringResource("shortcut.addExpense.resultError")
    }
    
    enum AddIncome {
        static let resultSuccess = NSLocalizedString("shortcut.addIncome.resultSuccess", comment: "")
        static let resultError = LocalizedStringResource("shortcut.addIncome.resultError")
    }
    
    enum PendingReimbursements {
        static let notExpectingResultSuccess = NSLocalizedString("shortcut.pendingReimbursements.notExpecting.resultSuccess", comment: "")
        static let expectingResultSuccess = NSLocalizedString("shortcut.pendingReimbursements.expecting.resultSuccess", comment: "")
        static let resultError = LocalizedStringResource("shortcut.pendingReimbursements.resultError")
    }
    
    enum Balance {
        static let resultSuccess = NSLocalizedString("shortcut.balance.resultSuccess", comment: "")
        static let resultError = LocalizedStringResource("shortcut.checkBalance.resultError")
    }
    
    enum MonthlySaved {
        static let resultSuccess = NSLocalizedString("shortcut.savedThisMonth.resultSuccess", comment: "")
        static let resultError = LocalizedStringResource("shortcut.savedThisMonth.resultError")
    }
    
    enum MonthlySpent {
        static let resultSuccess = NSLocalizedString("shortcut.spentThisMonth.resultSuccess", comment: "")
        static let resultError = LocalizedStringResource("shortcut.spentThisMonth.resultError")
    }
}
