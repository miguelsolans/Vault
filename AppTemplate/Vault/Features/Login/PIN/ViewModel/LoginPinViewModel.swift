//
//  LoginPinViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 04/04/2026.
//

import UIKit
import VaultCore

protocol LoginPinViewModelDelegate: AnyObject {
    func loginPinViewModelDidAuthenticate(_ viewModel: LoginPinViewModel);
}

final class LoginPinViewModel: NSObject {
    
    weak var delegate: LoginPinViewModelDelegate?
    
    // MARK: - Dependencies
    
    fileprivate let keychain: KeychainManager
    
    init(keychain: KeychainManager) {
        self.keychain = keychain
        super.init()
        
        self.setupBindings()
    }
    
    // MARK: - Input fields
    
    lazy var pinViewModel: PinViewModel = {
        let viewModel = PinViewModel(title: NSLocalizedString("login_pin_enter_pin", tableName: "LoginPin", comment: ""), subtitle: NSLocalizedString("login_enter_digit_pin", tableName: "LoginPin", comment: ""), numberOfDigits: 4, hasFaceID: false)
        
        return viewModel
    }()
}

extension LoginPinViewModel {
    func setupBindings() {
        
        pinViewModel.onDidEnterPin = { pin in
            
            self.validatePin(pin)
        }
        
        pinViewModel.onDidTapFaceID = {
            
        }
    }
}

extension LoginPinViewModel {
    
    func validatePin(_ pin: String) {
        
        let result = keychain.verifyPIN(pin)
        
        if(result) {
            delegate?.loginPinViewModelDidAuthenticate(self)
        }
    }
}
