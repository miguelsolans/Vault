//
//  CategoryTableViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 16/04/2026.
//

import Foundation

public final class CategoryTableViewModel: NSObject {
    
    private(set) var color: String
    
    private(set) var emoji: String?
    
    private(set) var title: String
    
    private(set) var subtitle: String
    
    private(set) var canDelete: Bool
    
    init(
        color: String,
        emoji: String? = nil,
        title: String,
        subtitle: String,
        canDelete: Bool = false
    ) {
        self.color = color
        self.emoji = emoji
        self.title = title
        self.subtitle = subtitle
        self.canDelete = canDelete
    }
}
