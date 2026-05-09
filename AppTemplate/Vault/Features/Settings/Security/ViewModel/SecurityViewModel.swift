//
//  SecurityViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 03/04/2026.
//

import UIKit
import VaultCore

protocol SecurityViewModelDelegate: AnyObject {
    func securityDidSelectOption(_ option: SecurityOption)
}

class SecurityViewModel: NSObject {
    
    weak var delegate: SecurityViewModelDelegate?
    
    // MARK: - Dependencies
    
    fileprivate let userDefaults: UserDefaultsManager
    
    init(userDefaults: UserDefaultsManager) {
        self.userDefaults = userDefaults
    }

    // MARK: - Input fields
    
    lazy var securityOptionsViewModel: [SecurityOptionsTableViewModel] = {
        [
            .init(sectionTitle: NSLocalizedString("security_authentication", tableName: "Security", comment: ""), options: [
                .init(option: .changePin, title: NSLocalizedString("security_pin", tableName: "Security", comment: ""), subtitle:NSLocalizedString("security_pin_subtitle", tableName: "Security", comment: ""), imageName:"lock.shield", style: (hasPinAuthentication ? .toggle : .navigable), isToggleOn: hasPinAuthentication, isEnabled: true),
                .init(option: .biometricAuthentication, title: NSLocalizedString("security_biometric", tableName: "Security", comment: ""), subtitle:NSLocalizedString("security_biometric_subtitle", tableName: "Security", comment: ""), imageName:"faceid", style: .toggle, valueText: "Disabled", isToggleOn: UserDefaultsManager.shared.hasBiometricAuthentication, isEnabled: false)
            ]),
            
            .init(sectionTitle: NSLocalizedString("security_options", tableName: "Security", comment: ""), options: [
                .init(option: .autoLock, title: NSLocalizedString("security_auto_lock", tableName: "Security", comment: ""), imageName:"", style: .disabled, valueText:(hasPinAuthentication ? NSLocalizedString("security_immediately", tableName: "Security", comment: "") : NSLocalizedString("security_never", tableName: "Security", comment: ""))),
                .init(option: .requireAuthentication, title: NSLocalizedString("security_requires_authentication", tableName: "Security", comment: ""), subtitle: NSLocalizedString("security_requires_authentication_subtitle", tableName: "Security", comment: ""), style: .toggle, isToggleOn:hasPinAuthentication, isEnabled: false)
            ])
        ]
    }()
    
    // MARK: - State
    
    var hasPinAuthentication: Bool {
        return userDefaults.hasPinAuthentication
    }
    
    // MARK: - Table
    
    var numberOfSections: Int { securityOptionsViewModel.count }
    
    func numberOfRows(at index: Int) -> Int { securityOptionsViewModel[index].options.count }
    
    func cellViewModel(at indexPath: IndexPath) -> SecurityOptionTableViewModel { securityOptionsViewModel[indexPath.section].options[indexPath.row] }
    
    func textForHeader(at index: Int) -> String { securityOptionsViewModel[index].sectionTitle }
    
    // MARK: - Bindings
    var updateUI: (() -> Void)?
}

// MARK: - Actions

extension SecurityViewModel {
    func toggleChanged(to value: Bool, from index: IndexPath) {
        
        var viewModel = cellViewModel(at: index)
        
        if(viewModel.option == SecurityOption.changePin) {
            userDefaults.hasPinAuthentication = value
            
            userDefaults.requiresPinOnLaunch = value
            
            viewModel.style = (hasPinAuthentication ? .toggle : .navigable)
            
            viewModel.isToggleOn = value
            
        }
        
        updateUI?()
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        
        let viewModel = cellViewModel(at: indexPath)
        
        if(viewModel.style == .navigable) {
            delegate?.securityDidSelectOption(viewModel.option)
        }
    }
}
