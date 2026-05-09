//
//  ReceiptAssistant.swift
//  Vault
//
//  Created by Miguel Solans on 18/04/2026.
//

import Foundation
import FoundationModels

@Generable
struct ReceiptOutput {
    @Guide(description: "The total amount of the receipt")
    let amount: Double?
    
    @Guide(description: "A description of description")
    let description: String?
    
    @Guide(description: "The category where the expense might fall into")
    let category: String?
}

final class ReceiptAssistant {
    
    private let session: LanguageModelSession
    
    public let categories: String
   
    init(categories: String) {
        self.categories = categories
        
        self.session = LanguageModelSession(
            instructions: """
                You decode terminal and ATM receipts.
                Extract the total amount and description, if available try to match with one of the following categories:
                
                \(categories)
                
                Do not invent data. If you're not really confident about any of the fields, ignore them.
                """
        )
    }
   
    func decodeReceipt(from text: String) async throws -> ReceiptOutput {
        let response = try await session.respond(
            to: text,
            generating: ReceiptOutput.self
        )
        
        return response.content
    }
}

