//
//  InitialDepositOutput.swift
//  Vault
//
//  Created by Miguel Solans on 13/04/2026.
//

import Foundation
import FoundationModels
import VaultCore

@Generable
struct InitialDepositOutput {
    @Guide(description: "The initial deposit value")
    let amount: Double
}


struct InitialDepositTool: Tool {
    
    // let vaultRepo: VaultRepository
    
    let name = "initialDepositOfVault"
    
    let description = """
        Returns the number of the initial depisit in a Vault. 
        Use this when user asks how much money they had when they created the vault or its initial deposit.
        """
    
    @Generable
    struct Arguments {
        @Guide(description: "Name of the Vault, such as Savings")
        var name: String
    }
    
    func call(arguments: Arguments) async throws -> some PromptRepresentable {
        
        /*guard let vault = try vaultRepo.get(by: arguments.name) else {
            print("FinanceAssistant | Couldn't find Vault \(arguments.name)")
            throw NSError(domain: "FinanceAssistant", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Couldn't find Vault."
            ])
        }
        
        return InitialDepositOutput(amount: vault.initialDeposit)*/
        return ""
    }
    
}
