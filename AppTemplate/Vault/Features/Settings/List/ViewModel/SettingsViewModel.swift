//
//  SettingsViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 02/04/2026.
//

import UIKit
import VaultCore

protocol SettingsViewModelDelegate: AnyObject {
    func settingsDidSelectOption(_ option: SettingsOption)
    func settingsDidDeleteVault()
}

class SettingsViewModel: NSObject {
    
    weak var delegate: SettingsViewModelDelegate?
    
    // MARK: - Dependencies
    
    fileprivate let deleteDataUseCase: DeleteAllDataUseCase
    
    init(
        deleteDataUseCase: DeleteAllDataUseCase
    ) {
        self.deleteDataUseCase = deleteDataUseCase
    }
    
    // MARK: - State
    
    lazy var items: [MenuOptionTableViewModel] = {
        return [
            .init(
                option: .vaults,
                title: NSLocalizedString("settings_vaults", tableName: "Settings", comment: ""),
                subtitle: NSLocalizedString("settings_manage_vaults", tableName: "Settings", comment: ""),
                imageName: "lock.square.stack",
                style: .navigable
            ),
            .init(
                option: .security,
                title: NSLocalizedString("settings_security", tableName: "Settings", comment: ""),
                subtitle: NSLocalizedString("settings_pin_and_biometric_authentication", tableName: "Settings", comment: ""),
                imageName: "lock.shield",
                style: .navigable
            ),
            .init(
                option: .about,
                title: NSLocalizedString("settings_about", tableName: "Settings", comment: ""),
                subtitle: NSLocalizedString("settings_app_version_and_information", tableName: "Settings", comment: ""),
                imageName: "info.circle",
                style: .disabled
            ),
            .init(
                option: .deleteAllData,
                title: NSLocalizedString("settings_delete_action", tableName: "Settings", comment: ""),
                subtitle: NSLocalizedString("settings_delete_information_message", tableName: "Settings", comment: ""),
                imageName: "trash",
                style: .destructive
            )
        ]
    }()
    
    var numberOfRows: Int { items.count }
    
    func cellViewModel(at indexPath: IndexPath) -> MenuOptionTableViewModel { items[indexPath.row] }
    
}

// MARK: - Actions
extension SettingsViewModel {
    
    func didSelectRowAtIndex(at indexPath: IndexPath) {
        let cellViewModel = cellViewModel(at: indexPath)
        
        switch cellViewModel.option {
        case .vaults:
            delegate?.settingsDidSelectOption(cellViewModel.option)
        case .security:
            delegate?.settingsDidSelectOption(cellViewModel.option)
            print("Go to security")
        case .about:
            print("Go to about")
        case .deleteAllData:
            break
        }
    }
}

// MARK: -
extension SettingsViewModel {
    func deleteData() {
        
        do {
            
            let request = DeleteAllDataRequest()
            
            _ = try deleteDataUseCase.execute(request)
            
            delegate?.settingsDidDeleteVault()
            
        } catch {
            // TODO: Present error?
        }
        
    }
}
