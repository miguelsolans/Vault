//
//  ActionableCardBaseViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 06/05/2026.
//

import Foundation
import AppUIKit

open class ActionableCardBaseViewModel {
    
    public var onTap: (() -> Void)?
    
    /// The title of the input field
    let title: String
    
    /// Marks whether the field user interaction is enable
    let isEnabled: Bool
    
    public init(title: String, isEnabled: Bool = true) {
        self.title = title
        self.isEnabled = isEnabled
    }
    
    public func didTap() {
        onTap?()
    }
}
