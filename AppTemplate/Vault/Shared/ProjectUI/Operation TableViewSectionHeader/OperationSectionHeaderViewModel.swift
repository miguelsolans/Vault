//
//  OperationSectionHeaderViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 30/03/2026.
//

import UIKit
import AppUIKit

public final class OperationSectionHeaderViewModel {
    
    let date: Date
    let amount: Double
    
    private let calendar = Calendar.current
    
    init(date: Date, amount: Double) {
        self.date = date
        self.amount = amount
    }
    
    // MARK: - Formatted
    
    var day: String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }
    
    var weekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var monthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    var formattedAmount: String {
        return LocalizedDecimalFormatter(numberStyle: .currency).string(from: amount) ?? "\(amount)"
    }
}
