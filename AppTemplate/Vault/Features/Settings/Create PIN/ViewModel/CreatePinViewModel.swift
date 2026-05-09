//
//  CreatePinViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 03/04/2026.
//

import UIKit
import VaultCore

protocol CreatePinViewModelDelegate: AnyObject {
    func createPinDidCreatePin();
    func createPinDidEnrollFaceID();
}

class CreatePinViewModel: NSObject {
    
    weak var delegate: CreatePinViewModelDelegate?
    
    // MARK: - Dependencies
    
    fileprivate let userDefaults: UserDefaultsManager
    
    fileprivate let keychain: KeychainManager
    
    init(userDefaults: UserDefaultsManager, keychain: KeychainManager) {
        self.userDefaults = userDefaults
        self.keychain = keychain
        
        super.init()
        
        pinViewModel.onDidEnterPin = { pin in
            
            self.setupPin(pin)
        }
        
        pinViewModel.onDidTapFaceID = {
            
            self.delegate?.createPinDidEnrollFaceID()
        }
    }
    
    // MARK: - Input fields
    
    lazy var pinViewModel: PinViewModel = {
        let viewModel = PinViewModel(
            title: NSLocalizedString("create_pin_title", tableName: "CreatePIN", comment: ""),
            subtitle: NSLocalizedString("create_pin_number_of_digits", tableName: "CreatePIN", comment: ""),
            numberOfDigits: 4,
            hasFaceID: false
        )
        
        return viewModel
    }();
    
}

extension CreatePinViewModel {
    func setupPin(_ pin: String) {
        
        let result = keychain.savePIN(pin)
        
        userDefaults.requiresPinOnLaunch = true
        
        if(result) {
            userDefaults.hasPinAuthentication = true
            
            delegate?.createPinDidCreatePin()
        }
        
    }
    
    func setupFaceID() {
        userDefaults.hasBiometricAuthentication = true
        
        userDefaults.requiresPinOnLaunch = true
        
        delegate?.createPinDidEnrollFaceID()
    }
}
