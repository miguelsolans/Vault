//
//  ExpectedReimbursementsIntent.swift
//  Vault
//
//  Created by Miguel Solans on 26/05/2026.
//

import AppIntents
import VaultCore
import AppUIKit

struct ExpectedReimbursementsIntent: AppIntent {
    
    static var title: LocalizedStringResource = "shortcut.pendingReimbursements.shortTitle"
    
    static var description = IntentDescription("shortcut.pendingReimbursements.description")

    static var parameterSummary: some ParameterSummary {
        Summary("shortcut.pendingReimbursements.shortTitle")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        let useCase = DependenciesContainer.shared.getStatisticsUseCase()
        
        let userDefaults = UserDefaultsManager.shared
        
        guard let vault = userDefaults.favoriteVault,
                let vaultID = UUID(uuidString: vault) else {
            return .result(
                dialog: IntentDialog(L10n.Shortcuts.noFavoriteVaultError)
            )
        }
        
        do {
            let request = StatisticsRequest(
                vaultID: vaultID
            )
            
            let response = try useCase.execute(request)
            
            let reimbursements = response.metrics.reimbursements;
            
            var message: String = ""
            
            if reimbursements.expected <= 0 && reimbursements.sameVaultReceived > 0 {
                
                let formattedAmount = LocalizedDecimalFormatter(numberStyle: .currency)
                    .string(from: reimbursements.sameVaultReceived) ?? "\(reimbursements.sameVaultReceived)"
                
                message = String(
                    format: L10n.Shortcuts.PendingReimbursements.notExpectingResultSuccess,
                    formattedAmount
                )
                
            } else if reimbursements.expected > 0 {
                
                let expectingFormatted = LocalizedDecimalFormatter(numberStyle: .currency)
                    .string(from: reimbursements.sameVaultReceived) ?? "\(reimbursements.expected)"
                
                let receivedFormatted = LocalizedDecimalFormatter(numberStyle: .currency)
                    .string(from: reimbursements.sameVaultReceived) ?? "\(reimbursements.sameVaultReceived)"
                
                message = String(
                    format: L10n.Shortcuts.PendingReimbursements.expectingResultSuccess,
                    expectingFormatted,
                    receivedFormatted
                )
            }
            
            return .result(
                dialog: IntentDialog(stringLiteral: message)
            )
            
        } catch {
            return .result(
                dialog: IntentDialog(L10n.Shortcuts.PendingReimbursements.resultError)
            )
        }
        
    }
}
