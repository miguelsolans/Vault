//
//  OperationMetricsTool.swift
//  Vault
//
//  Created by Miguel Solans on 20/04/2026.
//

import Foundation
import FoundationModels
import VaultCore

@Generable
struct OperationMetricsOutput {
    @Guide(description: "The initial net value of the Vault")
    let initialDeposit: Double
    
    @Guide(description: "The total income in the current year")
    let totalIncome: Double
    
    @Guide(description: "The total value spent in the current year")
    let totalSpent: Double
    
    @Guide(description: "The total income in the current month")
    let income: Double
    
    @Guide(description: "The total value spent in the current month")
    let spent: Double
    
    @Guide(description: "The average income in the current month")
    let averageIncome: Double
    
    @Guide(description: "The average spent in the current month")
    let averageSpent: Double
    
    @Guide(description: "How much has been saved in a year")
    let totalSaved: Double
    
    @Guide(description: "How much has been saved in the current month")
    let saved: Double
    
    @Guide(description: "The saving efficiency in the curret month")
    let savingEfficiency: Double
    
    @Guide(description: "The total saving effiency in the year")
    let totalSavingEfficiency: Double
    
    @Guide(description: "The total net value of the Vault")
    let totalInVault: Double
}

struct OperationMetricsTool: Tool {
    
    let useCase: StatisticsUseCase
    
    let description = """
        Return information regarding an account or Vault, namely:
        - The initial deposit of the account
        - The total income in a year
        - The total money spent in a year
        - The total income in a given month
        - The total expenses in a given month
        - Average of money earned in a month
        - Average of money spent in a month
        - How much money has been saved
        - Saving efficiency of the current month
        - Saving efficiency in a year
        - The balance of the account
        
        Do not invent any of the data. Be precise. If you can't find the answers for, say so clearly.
    """
    
    @Generable
    struct Arguments {
        @Guide(description: "Name of the Vault or account")
        let name: String
        
        @Guide(description: "The month expressed in a number from 1 to 12")
        let month: Int?
        
        @Guide(description: "The year")
        let year: Int?
        
        var date: Date? {
            var components = DateComponents()
            
            components.year = year
            components.month = month
            
            return Calendar.current.date(from: components)
        }
    }
    
    func call(arguments: Arguments) async throws -> String { // OperationMetricsOutput {
        
        guard let vault = UserDefaultsManager.shared.favoriteVault else {
            throw NSError(
                domain: "FinanceAssistant",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "No default Vault provided"]
            )
        }
        
        guard let vaultID = UUID(uuidString: vault) else {
            throw NSError(
                domain: "FinanceAssistant",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Not a valid Vault identifier"]
            )
        }
        
        let request = StatisticsRequest(
            vaultID: vaultID,
            startDate: arguments.date?.monthStart(),
            endDate: arguments.date?.monthEnd(),
            period: .monthly
        )
        
        let response = try useCase.execute(request)
        
        return "" /*OperationMetricsOutput(
            initialDeposit: response.metrics.initialDeposit,
            totalIncome: response.metrics.totalIncome,
            totalSpent: response.metrics.totalSpent,
            income: response.metrics.income,
            spent: response.metrics.spent,
            averageIncome: response.metrics.averageIncome,
            averageSpent: response.metrics.averageSpent,
            totalSaved: response.metrics.totalSaved,
            saved: response.metrics.saved,
            savingEfficiency: response.metrics.savingEfficiency,
            totalSavingEfficiency: response.metrics.totalSavingEfficiency,
            totalInVault: response.metrics.totalInVault
        )*/
    }
}
