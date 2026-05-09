//
//  LoginViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 04/04/2026.
//

import UIKit
import VaultCore

enum LoginType {
    case pin
    case biometric
}

protocol LoginViewModelDelegate: AnyObject {
    
    func didTapLogin(with type: LoginType)

}

class LoginViewModel: NSObject {
    
    weak var delegate: LoginViewModelDelegate?
    
    // MARK: - Dependencies
    
    private let userDefaults: UserDefaultsManager
    
    private let keychain: KeychainManager
    
    init(
        userDefaults: UserDefaultsManager,
        keychain: KeychainManager
    ) {
        self.userDefaults = userDefaults
        self.keychain = keychain
    }
    
    // MARK: - State
    
    var hasBiometricAuthentication: Bool {
        userDefaults.hasBiometricAuthentication
    }
    
    // MARK: - Bindings
    
    var updateUI: (() -> Void)?
}

// MARK: - Actions

extension LoginViewModel {
    func didTapLogin(type: LoginType) {
        
        delegate?.didTapLogin(with: type)
    }
    
}
