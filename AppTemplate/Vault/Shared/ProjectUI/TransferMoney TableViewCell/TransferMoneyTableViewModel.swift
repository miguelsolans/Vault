//
//  TransferMoneyTableViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 30/04/2026.
//

import UIKit
import VaultCore

final class TransferMoneyTableViewModel: NSObject {
    
    let amount: String
    
    let sourceVaultName: String
    
    let destinationVaultName: String
    
    let status: ReimbursementStatus
    
    var sourceVaultText: String {
        "From: \(sourceVaultName)"
    }
    
    var statusText: String {
        switch status {
        case .expected:
            return "Expected"
        case .received:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }
    
    var statusColor: UIColor {
        switch status {
        case .expected:
            return .systemOrange
        case .received:
            return .systemGreen
        case .cancelled:
            return .secondaryLabel
        }
    }
    
    init(
        amount: String,
        sourceVaultName: String,
        destinationVaultName: String,
        status: ReimbursementStatus
    ) {
        self.amount = amount
        self.sourceVaultName = sourceVaultName
        self.destinationVaultName = destinationVaultName
        self.status = status
    }
}
