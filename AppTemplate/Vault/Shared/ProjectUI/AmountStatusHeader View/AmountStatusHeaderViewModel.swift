//
//  AmountStatusHeaderViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 09/05/2026.
//

import UIKit
import AppUIKit
import VaultCore

final class AmountStatusHeaderViewModel: NSObject {
    
    private(set) var amount: Double
    
    private(set) var percentage: Double
    
    private(set) var operationType: OperationType
    
    private(set) var period: Period
    
    init(
        amount: Double,
        percentage: Double,
        operationType: OperationType,
        period: Period
    ) {
        self.amount = amount
        self.percentage = percentage
        self.operationType = operationType
        self.period = period
    }
    
    public var formattedAmount: String {
        get {
            return currencyFormatter.string(from: amount) ?? "\(amount)"
        }
    }
    
    public var formattedPercentage: String {
        get {
            numberFormatter.string(from: percentage) ?? "\(percentage)"
        }
    }
    
    public var percentageColor: UIColor {
        if percentage == 0 {
            return .label
        }
        
        switch operationType {
        case .income:
            return percentage > 0 ? .systemGreen : .systemRed
        case .expense:
            return percentage > 0 ? .systemRed : .systemGreen
        }
    }
    
    public var isPercentageHidden: Bool {
        get {
            percentage == 0
        }
    }
    
    private var currencyFormatter: LocalizedDecimalFormatter {
        LocalizedDecimalFormatter(numberStyle: .currency)
    }
    
    private var numberFormatter: LocalizedDecimalFormatter {
        LocalizedDecimalFormatter(numberStyle: .percent)
    }
}
