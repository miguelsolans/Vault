//
//  MonthlySpentIntent.swift
//  Vault
//
//  Created by Miguel Solans on 27/05/2026.
//

import AppIntents
import VaultCore
import AppUIKit

struct MonthlySpentIntent: AppIntent {
    
    static var title: LocalizedStringResource = "shortcut.spentThisMonth.shortTitle"
    
    static var description = IntentDescription("shortcut.spentThisMonth.description")
    
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    static var parameterSummary: some ParameterSummary {
        Summary("shortcut.spentThisMonth.shortTitle")
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
                vaultID: vaultID,
                startDate: Date().monthStart(),
                endDate: Date().monthEnd(),
                period: .monthly
            )
            
            let response = try useCase.execute(request)
            
            let amount = response.metrics.netSpending.netExpenses
            
            let text = String(
                format: L10n.Shortcuts.MonthlySpent.resultSuccess,
                LocalizedDecimalFormatter(numberStyle: .currency)
                    .string(from: amount) ?? "\(amount)"
            )
            
            return .result(
                dialog: IntentDialog(stringLiteral: text)
            )
            
        } catch {
            return .result(
                dialog: IntentDialog(L10n.Shortcuts.MonthlySpent.resultError)
            )
        }
    }
}
