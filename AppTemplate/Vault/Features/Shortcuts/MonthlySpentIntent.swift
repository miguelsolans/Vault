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
    
    static var title: LocalizedStringResource = "Spent this month"
    
    static var description = IntentDescription("How much has been spent this month")
    
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    static var parameterSummary: some ParameterSummary {
        Summary("Monthly Spent")
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
                vaultID: vaultID,
                startDate: Date().monthStart(),
                endDate: Date().monthEnd(),
                period: .monthly
            )
            
            let response = try useCase.execute(request)
            
            let currencyFormatter = LocalizedDecimalFormatter(numberStyle: .currency)
            
            let formattedAmount = currencyFormatter
                .string(from: response.dashboardMetrics.netSpending.netExpenses) ?? "\(response.dashboardMetrics.netSpending.netExpenses)"
            
            return .result(
                dialog: IntentDialog(stringLiteral: "This month, you spent \(formattedAmount)")
            )
            
        } catch {
            return .result(
                dialog: IntentDialog("Failed to fetch information from Vault.")
            )
        }
    }
}
