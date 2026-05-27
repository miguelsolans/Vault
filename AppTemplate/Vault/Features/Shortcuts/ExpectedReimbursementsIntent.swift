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
    
    static var title: LocalizedStringResource = "Expected reimbursement"
    
    static var description = IntentDescription("Check if there are any pending reimbursements in Vault.")

    static var parameterSummary: some ParameterSummary {
        Summary("Expecting reimbursements")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        let useCase = DependenciesContainer.shared.getDashboardUseCase()
        
        let userDefaults = UserDefaultsManager.shared
        
        guard let vault = userDefaults.favoriteVault,
                let vaultID = UUID(uuidString: vault) else {
            return .result(
                dialog: IntentDialog("No favourite Vault has been configured.")
            )
        }
        
        do {
            let request = DashboardRequest(
                vaultID: vaultID
            )
            
            let response = try useCase.execute(request)
            
            let reimbursements = response.dashboardMetrics.reimbursements;
            
            var message: String = ""
            
            if reimbursements.expected <= 0 && reimbursements.sameVaultReceived > 0 {
                let formattedAmount = LocalizedDecimalFormatter(numberStyle: .currency)
                    .string(from: reimbursements.sameVaultReceived) ?? "\(reimbursements.sameVaultReceived)"
                
                message = "You are not expecting any money. So far, you've received \(formattedAmount)."
            } else if reimbursements.expected > 0 {
                
                let expectingFormatted = LocalizedDecimalFormatter(numberStyle: .currency)
                    .string(from: reimbursements.sameVaultReceived) ?? "\(reimbursements.expected)"
                
                let receivedFormatted = LocalizedDecimalFormatter(numberStyle: .currency)
                    .string(from: reimbursements.sameVaultReceived) ?? "\(reimbursements.sameVaultReceived)"
                
                message = "You are expecting \(expectingFormatted). So far, you've received \(receivedFormatted)."
            }
            
            return .result(
                dialog: IntentDialog(stringLiteral: message)
            )
            
        } catch {
            return .result(
                dialog: IntentDialog("Failed to fetch information from Vault.")
            )
        }
        
    }
}
