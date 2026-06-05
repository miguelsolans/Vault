//
//  CustomizeDashboardTableViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 05/06/2026.
//

import UIKit

public final class CustomizeDashboardTableViewModel: NSObject {
    
    public let id: UUID
    
    public let imageName: String?
    
    public let title: String
    
    public let subtitle: String?
    
    public let isToggleOn: Bool
    
    public let isEnabled: Bool
    
    init(
        id: UUID,
        imageName: String? = nil,
        title: String,
        subtitle: String? = nil,
        isToggleOn: Bool,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.isToggleOn = isToggleOn
        self.isEnabled = isEnabled
    }
}
