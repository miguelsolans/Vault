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

final class SecurityViewModel: NSObject {
    
    weak var delegate: SecurityViewModelDelegate?
    
    // MARK: - Dependencies
    
    private let securityInfoUseCase: SecurityInfoUseCase
    
    private let securityInfoUpdateUseCase: SecurityInfoUpdateUseCase
    
    init(
        securityInfoUseCase: SecurityInfoUseCase,
        securityInfoUpdateUseCase: SecurityInfoUpdateUseCase
    ) {
        self.securityInfoUseCase = securityInfoUseCase
        self.securityInfoUpdateUseCase = securityInfoUpdateUseCase
    }
    
    // MARK: - UI State
    
    public var securityOptionsViewModel: [SecurityOptionsTableViewModel] = []
    
    public var numberOfSections: Int { securityOptionsViewModel.count }
    
    public func numberOfRows(at index: Int) -> Int { securityOptionsViewModel[index].options.count }
    
    public func cellViewModel(at indexPath: IndexPath) -> SecurityOptionTableViewModel { securityOptionsViewModel[indexPath.section].options[indexPath.row] }
    
    public func textForHeader(at index: Int) -> String { securityOptionsViewModel[index].sectionTitle }
    
    // MARK: - Bindings
    
    public var updateUI: (() -> Void)?
}

// MARK: - Data
extension SecurityViewModel {
    func getData() {
        let request = SecurityInfoRequest()
        
        let useCase = DependenciesContainer.shared.getSecurityInfoUseCase()
        
        let response = useCase.execute(request)
        
        updateVM(with: response)
        
        updateUI?()
    }
    
    private func updateVM(with response: SecurityInfoResponse) {
        let pinOptionViewModel = SecurityOptionTableViewModel(
            option: .changePin,
            title: NSLocalizedString("security_pin", tableName: "Security", comment: ""),
            subtitle:NSLocalizedString("security_pin_subtitle", tableName: "Security", comment: ""),
            imageName:"lock.shield",
            style: (response.pinEnabled ? .toggle : .navigable),
            isToggleOn: response.pinEnabled,
            isEnabled: true
        )
        
        let biometricOptionViewModel = SecurityOptionTableViewModel(
            option: .biometricAuthentication,
            title: NSLocalizedString("security_biometric", tableName: "Security", comment: ""),
            subtitle:NSLocalizedString("security_biometric_subtitle", tableName: "Security", comment: ""),
            imageName:"faceid",
            style: .toggle,
            valueText: "Disabled",
            isToggleOn: UserDefaultsManager.shared.hasBiometricAuthentication,
            isEnabled: false
        )
        
        let autolockOptionViewModel = SecurityOptionTableViewModel(
            option: .autoLock,
            title: NSLocalizedString("security_auto_lock", tableName: "Security", comment: ""),
            imageName:"",
            style: .disabled,
            valueText: (response.authenticationEnabled ? NSLocalizedString("security_immediately", tableName: "Security", comment: "") : NSLocalizedString("security_never", tableName: "Security", comment: ""))
        )
        
        let requirementOptionViewModel = SecurityOptionTableViewModel(
            option: .requireAuthentication,
            title: NSLocalizedString("security_requires_authentication", tableName: "Security", comment: ""),
            subtitle: NSLocalizedString("security_requires_authentication_subtitle", tableName: "Security", comment: ""),
            style: .toggle,
            isToggleOn: response.authenticationEnabled,
            isEnabled: false
        )
        
        let authenticationViewModel = SecurityOptionsTableViewModel(sectionTitle: "Authentication", options: [ pinOptionViewModel, biometricOptionViewModel ])
        let optionsViewModel = SecurityOptionsTableViewModel(sectionTitle: "Option", options: [ autolockOptionViewModel, requirementOptionViewModel ])
        
        securityOptionsViewModel = [ authenticationViewModel, optionsViewModel ];
    }
    
    private func update(pinEnabled: Bool) {
        let request = SecurityInfoUpdateRequest(
            authenticationEnabled: pinEnabled,
            pinEnabled: pinEnabled,
            biometricEnabled: pinEnabled,
            autolock: 0
        )
        
        _ = securityInfoUpdateUseCase.execute(request)
        
        getData()
    }
}

// MARK: - Actions

extension SecurityViewModel {
    func toggleChanged(to value: Bool, from index: IndexPath) {
        
        let viewModel = cellViewModel(at: index)
        
        if(viewModel.option == SecurityOption.changePin) {
            
            update(pinEnabled: value)
        }
        
        getData()
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        
        let viewModel = cellViewModel(at: indexPath)
        
        if(viewModel.style == .navigable) {
            delegate?.securityDidSelectOption(viewModel.option)
        }
    }
}
