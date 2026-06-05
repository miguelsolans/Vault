//
//  CheckBalanceIntent.swift
//  Vault
//
//  Created by Miguel Solans on 27/05/2026.
//

import AppIntents
import VaultCore
import AppUIKit

struct CheckBalanceIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Check balance"
    
    static var description = IntentDescription("Check the balance of favorite Vault.")
    
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    static var parameterSummary: some ParameterSummary {
        Summary("Check balance")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        let useCase = DependenciesContainer.shared.getStatisticsUseCase()
        
        let userDefaults = UserDefaultsManager.shared
        
        guard let vault = userDefaults.favoriteVault,
                let vaultID = UUID(uuidString: vault) else {
            return .result(
                dialog: IntentDialog("No favourite Vault has been configured.")
            )
        }
        
        do {
            
            let request = StatisticsRequest(
                vaultID: vaultID
            )
            
            let response = try useCase.execute(request)
            
            let formattedBalance = LocalizedDecimalFormatter(numberStyle: .currency)
                .string(from: response.metrics.balance.currentBalance) ?? "\(response.metrics.balance.currentBalance)"
            
            let message: String = "The current balance of Vault \(response.vault) is \(formattedBalance)"
            
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
