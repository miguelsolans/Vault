//
//  SettingsViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 02/04/2026.
//

import UIKit
import CoreKit
import VaultCore

protocol SettingsViewModelDelegate: AnyObject {
    func didSelectOption(_ viewModel: SettingsViewModel,option: SettingsOption)
    func didDeleteAllData(_ viewModel: SettingsViewModel)
}

final class SettingsViewModel: NSObject {
    
    weak var delegate: SettingsViewModelDelegate?
    
    // MARK: - Dependencies
    
    fileprivate let deleteDataUseCase: DeleteAllDataUseCase
    
    init(
        deleteDataUseCase: DeleteAllDataUseCase
    ) {
        self.deleteDataUseCase = deleteDataUseCase
    }
    
    // MARK: - UI State
    
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
    
    public var numberOfRows: Int { items.count }
    
    public func cellViewModel(at indexPath: IndexPath) -> MenuOptionTableViewModel { items[indexPath.row] }
    
    // MARK: - Bindings
    
    public var onSuccess: ((ViewModelFeedback) -> Void)?
    
    public var onError: ((ViewModelFeedback) -> Void)?
    
}

// MARK: - Actions
extension SettingsViewModel {
    
    public func didSelectRowAtIndex(at indexPath: IndexPath) {
        let cellViewModel = cellViewModel(at: indexPath)
        
        switch cellViewModel.option {
        case .vaults:
            delegate?.didSelectOption(self, option: cellViewModel.option)
            break
        case .security:
            delegate?.didSelectOption(self, option: cellViewModel.option)
            break
        case .about:
            break
        case .deleteAllData:
            break
        }
    }
    
    public func didTapDeleteAllData() {
        deleteData()
    }
}

// MARK: - Data
extension SettingsViewModel {
    private func deleteData() {
        
        do {
            
            let request = DeleteAllDataRequest()
            
            _ = try deleteDataUseCase.execute(request)
            
            onSuccess?(.silent)
            
            delegate?.didDeleteAllData(self)
            
        } catch {
            onError?(.showAlert(message: "There was an error deleting data. Try again later."))
        }
    }
}
