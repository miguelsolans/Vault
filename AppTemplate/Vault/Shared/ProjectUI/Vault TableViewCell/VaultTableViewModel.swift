//
//  VaultTableViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 08/04/2026.
//

import UIKit
import AppUIKit

class VaultTableViewModel: NSObject {
    public var title: String
    
    public var initialDeposit: Double
    
    public var currentBalance: Double
    
    public var isFavorite: Bool
    
    var formattedInitialDeposit: String {
        LocalizedDecimalFormatter(numberStyle: .currency)
            .string(from: initialDeposit) ?? "\(initialDeposit)"
    }
    
    var formattedCurrentBalance: String {
        LocalizedDecimalFormatter(numberStyle: .currency)
            .string(from: currentBalance) ?? "\(currentBalance)"
    }
    
    var initialDepositText: String {
        "Started with \(formattedInitialDeposit)"
    }
    
    init(title: String,
         initialDeposit: Double,
         currentBalance: Double,
         isFavorite: Bool = false) {
        self.title = title
        self.initialDeposit = initialDeposit
        self.currentBalance = currentBalance
        self.isFavorite = isFavorite
    }
}
