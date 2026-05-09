//
//  MenuOptionTableViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 02/04/2026.
//

import Foundation

enum SettingsOption {
    case vaults
    case security
    case about
    case deleteAllData
}

enum MenuOptionStyle {
    case navigable
    case destructive
    case toggle
    case disabled
}

struct MenuOptionTableViewModel {
    let option: SettingsOption
    let title: String
    let subtitle: String?
    let imageName: String?
    let style: MenuOptionStyle
}
