//
//  CreatePinViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 03/04/2026.
//

import UIKit
import VaultCore

protocol CreatePinViewModelDelegate: AnyObject {
    func didCreatePin(_ viewModel: CreatePinViewModel);
    func didEnrollBiometric(_ viewModel: CreatePinViewModel);
}

final class CreatePinViewModel: NSObject {
    
    weak var delegate: CreatePinViewModelDelegate?
    
    // MARK: - Dependencies
    
    private let pinUseCase: SecurityPinSetupUseCase
    
    init(pinUseCase: SecurityPinSetupUseCase) {
        self.pinUseCase = pinUseCase
        
        super.init()
        
        setupBindings()
        
    }
    
    private func setupBindings() {
        pinViewModel.onDidEnterPin = { pin in
            
            self.setupPin(pin)
        }
        
        pinViewModel.onDidTapFaceID = {
            
            self.delegate?.didEnrollBiometric(self)
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
    private func setupPin(_ pin: String) {
        
        let request = SecurityPinSetupRequest(pin: pin)
        
        let response = pinUseCase.execute(request)
        
        if response.result {
            delegate?.didCreatePin(self)
        } else {
            // TODO: Feedback
        }
    }
    
    /*func setupFaceID() {
        userDefaults.hasBiometricAuthentication = true
        
        userDefaults.requiresPinOnLaunch = true
        
        delegate?.didEnrollBiometric()
    }*/
}
