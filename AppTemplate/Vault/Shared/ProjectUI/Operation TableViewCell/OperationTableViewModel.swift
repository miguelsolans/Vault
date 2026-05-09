//
//  OperationTableViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 30/03/2026.
//

import UIKit
import AppUIKit
import VaultCore

public final class OperationTableViewModel: NSObject {
    
    public var color: String
 
    public var title: String
    
    public var subtitle: String
    
    public var emoji: String?
    
    public var amount: Double
    
    public var operationType: OperationType
    
    public var numberOfReimbursements: Int
    
    public var expectedReimbursements: Int
    
    var formattedAmount: String {
        LocalizedDecimalFormatter(numberStyle: .currency)
            .string(from: amount) ?? "\(amount)"
    }
    
    init(
        color: String,
        emoji: String? = nil,
        title: String,
        subtitle: String,
        amount: Double,
        operationType: OperationType,
        numberOfReimbursements: Int,
        expectedReimbursements: Int
    ) {
        self.color = color
        self.emoji = emoji
        self.title = title
        self.subtitle = subtitle
        self.amount = amount
        self.operationType = operationType
        self.numberOfReimbursements = numberOfReimbursements
        self.expectedReimbursements = expectedReimbursements
    }
    
    
}

public final class OperationsTableViewModel: NSObject {
    
    public var section: OperationSectionHeaderViewModel
    
    public var items: [OperationTableViewModel]
    
    init(section: OperationSectionHeaderViewModel, items: [OperationTableViewModel]) {
        self.section = section
        self.items = items
    }
}

