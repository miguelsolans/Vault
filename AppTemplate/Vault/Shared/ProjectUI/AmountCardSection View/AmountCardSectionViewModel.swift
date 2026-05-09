//
//  AmountCardSectionViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 30/03/2026.
//

import UIKit
import VaultCore

public final class AmountCardItemViewModel: ActionableCardBaseViewModel {
    
    let amount: Double
    
    let type: OperationType?
    
    let budgetAmount: Double?
    
    let bottomText: String?
    
    let bottomAttributedText: AttributedString?
    
    init(
        title: String,
        amount: Double,
        type: OperationType?,
        budgetAmount: Double?,
        bottomText: String? = nil,
        bottomAttributedText: AttributedString? = nil
    ) {
        self.amount = amount
        self.type = type
        self.budgetAmount = budgetAmount
        self.bottomText = bottomText
        self.bottomAttributedText = bottomAttributedText
        super.init(title: title)
    }
}

public struct AmountCardSectionViewModel {
    let monthTitle: String
    
    let items: [AmountCardItemViewModel]
    
    let gridFormat: Bool
}
