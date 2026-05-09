//
//  AmountCardSectionViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 30/03/2026.
//

import UIKit
import VaultCore

public final class AmountCardItemViewModel: ActionableCardBaseViewModel {
    
    let emoji: String?
    
    let amount: Double
    
    let type: OperationType?
    
    let bottomText: String?
    
    let bottomAttributedText: AttributedString?
    
    init(
        emoji: String? = nil,
        title: String,
        amount: Double,
        type: OperationType?,
        bottomText: String? = nil,
        bottomAttributedText: AttributedString? = nil
    ) {
        self.emoji = emoji
        self.amount = amount
        self.type = type
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
