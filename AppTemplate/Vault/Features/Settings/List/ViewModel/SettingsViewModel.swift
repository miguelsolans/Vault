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
    
    public var title: String {
        return L10n.Settings.pageTitle
    }
    
    public var subtitle: String {
        return L10n.Settings.pageSubtitle
    }
    
    lazy var items: [MenuOptionTableViewModel] = {
        return [
            .init(
                option: .vaults,
                title: L10n.Settings.vaultsOptionTitle,
                subtitle: L10n.Settings.vaultsOptionDescription,
                imageName: "lock.square.stack",
                style: .navigable
            ),
            .init(
                option: .security,
                title: L10n.Settings.securityOptionTitle,
                subtitle: L10n.Settings.securityOptionDescription,
                imageName: "lock.shield",
                style: .navigable
            ),
            .init(
                option: .about,
                title: L10n.Settings.backupOptionTitle,
                subtitle: L10n.Settings.backupOptionDescription,
                imageName: "icloud",
                style: .disabled
            ),
            .init(
                option: .about,
                title: L10n.Settings.aboutOptionTitle,
                subtitle: L10n.Settings.aboutOptionDescription,
                imageName: "info.circle",
                style: .navigable
            ),
            .init(
                option: .deleteAllData,
                title: L10n.Common.delete,
                subtitle: L10n.Settings.deleteInformationDisclaimer,
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
        let option = cellViewModel(at: indexPath).option
        
        switch option {
        case .vaults, .security, .about:
            delegate?.didSelectOption(self, option: option)
            
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
            onError?(.showAlert(message: L10n.Settings.errorDeletingData))
        }
    }
}
