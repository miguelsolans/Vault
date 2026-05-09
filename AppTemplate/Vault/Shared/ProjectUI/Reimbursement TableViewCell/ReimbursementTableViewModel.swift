//
//  ReimbursementTableViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 05/05/2026.
//

import UIKit
import AppUIKit
import VaultCore

class ReimbursementTableViewModel: NSObject {
    
    private(set) var status: ReimbursementStatus

    private(set) var title: String
    
    private(set) var amount: Double
    
    var formattedAmount: String {
        currencyFormatter.string(from: amount) ?? "\(amount)"
    }
    
    init(
        status: ReimbursementStatus,
        title: String,
        amount: Double
    ) {
        self.status = status
        self.title = title
        self.amount = amount
    }
    
    private lazy var currencyFormatter: LocalizedDecimalFormatter = {
        LocalizedDecimalFormatter(numberStyle: .currency)
    }()
}
