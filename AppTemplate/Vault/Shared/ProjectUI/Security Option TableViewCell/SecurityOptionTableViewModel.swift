//
//  SecurityOptionTableViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 03/04/2026.
//

import UIKit

enum SecurityOption {
    case pinStatus
    case changePin
    case biometricAuthentication
    case requireAuthentication
    case autoLock
}

struct SecurityOptionTableViewModel {
    let option: SecurityOption
    let title: String
    let subtitle: String?
    let imageName: String?
    var style: MenuOptionStyle
    let valueText: String?
    var isToggleOn: Bool
    let isEnabled: Bool
    
    init(
        option: SecurityOption,
        title: String,
        subtitle: String? = nil,
        imageName: String? = nil,
        style: MenuOptionStyle,
        valueText: String? = nil,
        isToggleOn: Bool = false,
        isEnabled: Bool = true
    ) {
        self.option = option
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.style = style
        self.valueText = valueText
        self.isToggleOn = isToggleOn
        self.isEnabled = isEnabled
    }
}

struct SecurityOptionsTableViewModel {
    let sectionTitle: String
    var options: [SecurityOptionTableViewModel]
}
