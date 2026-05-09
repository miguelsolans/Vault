//
//  OperationDetailHeaderViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 05/05/2026.
//

import UIKit
import AppUIKit
import VaultCore

final class OperationDetailHeaderViewModel: NSObject {
    
    private(set) var emoji: String?
    
    private(set) var color: String
    
    private(set) var title: String
    
    private(set) var amount: Double

    private(set) var date: Date?
    
    public var formattedAmount: String {
        get {
            return currencyFormatter.string(from: amount) ?? "\(amount)"
        }
    }

    public var formattedDate: String? {
        guard let date else {
            return nil
        }

        return dateFormatter.string(from: date)
    }
    
    private(set) var operationType: OperationType
    
    init(
        emoji: String? = nil,
        color: String,
        title: String,
        amount: Double,
        date: Date? = nil,
        operationType: OperationType
    ) {
        self.emoji = emoji
        self.color = color
        self.title = title
        self.amount = amount
        self.date = date
        self.operationType = operationType
    }
    
    private var currencyFormatter: LocalizedDecimalFormatter {
        LocalizedDecimalFormatter(numberStyle: .currency)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}
