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
    
    public var title: String {
        L10n.Security.pageTitle
    }
    
    public var subtitle: String {
        L10n.Security.pageSubtitle
    }
    
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
            title: L10n.Security.pinOptionTitle,
            subtitle: L10n.Security.pinOptionDescription,
            imageName:"lock.shield",
            style: (response.pinEnabled ? .toggle : .navigable),
            isToggleOn: response.pinEnabled,
            isEnabled: true
        )
        
        let biometricOptionViewModel = SecurityOptionTableViewModel(
            option: .biometricAuthentication,
            title: L10n.Security.biometricOptionTitle,
            subtitle: L10n.Security.biometricOptionDescription,
            imageName:"faceid",
            style: .toggle,
            valueText: "Disabled",
            isToggleOn: UserDefaultsManager.shared.hasBiometricAuthentication,
            isEnabled: false
        )
        
        let autolockOptionViewModel = SecurityOptionTableViewModel(
            option: .autoLock,
            title: L10n.Security.autoLockOptionTitle,
            imageName: "",
            style: .disabled,
            valueText: (response.authenticationEnabled ? L10n.Security.immediately : L10n.Security.never)
        )
        
        let requirementOptionViewModel = SecurityOptionTableViewModel(
            option: .requireAuthentication,
            title: L10n.Security.requiresAuthenticationOptionTitle,
            subtitle: L10n.Security.requiresAuthenticationOptionDescription,
            style: .toggle,
            isToggleOn: response.authenticationEnabled,
            isEnabled: false
        )
        
        let authenticationViewModel = SecurityOptionsTableViewModel(sectionTitle: L10n.Security.authentication, options: [ pinOptionViewModel, biometricOptionViewModel ])
        let optionsViewModel = SecurityOptionsTableViewModel(sectionTitle: L10n.Security.option, options: [ autolockOptionViewModel, requirementOptionViewModel ])
        
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
