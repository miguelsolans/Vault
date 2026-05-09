//
//  FinanceAssistant.swift
//  Vault
//
//  Created by Miguel Solans on 13/04/2026.
//

import Foundation
import FoundationModels
import VaultCore

final class FinanceAssistant {
    
    private let session: LanguageModelSession
    
    private var dashboardUseCase: DashboardUseCase
    
    init(
        dashboardUseCase: DashboardUseCase
    ) {
        self.dashboardUseCase = dashboardUseCase
        
        self.session = LanguageModelSession(tools: [
            OperationMetricsTool(useCase: dashboardUseCase)
            
        ], instructions: """
            You are a finance asistant inside a budgeting app. 
            For questions about the user's financial data, use only the available tools.
            
            Do not invent numbers. If no data is available, say so clearly.
            If user asks anything unrelated to what we offer in the budgetting app, you will answer 'I don't have the answer to your question.'
            Prefer bullet-free short summaries unless asked otherwise.
            """
        )
    }
    
    public func answer(_ userPrompt: String) async throws -> String {
        let response = try await session.respond(to: userPrompt)
        return response.content
    }
}
