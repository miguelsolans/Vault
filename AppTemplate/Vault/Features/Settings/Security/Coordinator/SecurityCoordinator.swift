//
//  SecurityCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 03/04/2026.
//

import UIKit
import CoreKit

class SecurityCoordinator: BaseCoordinator {
    
    // MARK: - Dependencies
    
    let navigationController: UINavigationController
    
    fileprivate let dependencies: DependenciesContainer
    
    init(navigationController: UINavigationController, dependencies: DependenciesContainer) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = securityViewController
        self.navigationController.pushViewController(securityViewController, animated: true)
    }
    
    override func finish() {
        removeAllChildCoordinators()
    }
    
    // MARK: - ViewController's
    
    lazy var securityViewController: SecurityViewController = {
        
        let viewModel = dependencies.getSecurityViewModel()
        
        viewModel.delegate = self
        
        let viewController = SecurityViewController(viewModel: viewModel)
        
        return viewController
    }()
    
    lazy var createPinViewController: PinViewController = {
        let viewModel = dependencies.getCreatePinViewModel()
        
        viewModel.delegate = self
        
        let viewController = PinViewController(viewModel: viewModel.pinViewModel)
        
        return viewController
    }()
}

// MARK: - SecurityViewModel delegates

extension SecurityCoordinator: SecurityViewModelDelegate {
    func securityDidSelectOption(_ option: SecurityOption) {
        if(option == .changePin) {
            self.navigateToCreatePin()
        }
    }
}

// MARK: - CreatePinViewModel delegates

extension SecurityCoordinator: CreatePinViewModelDelegate {
    func didCreatePin(_ viewModel: CreatePinViewModel) {
        navigationController.popViewController(animated: true)
    }
    
    func didEnrollBiometric(_ viewModel: CreatePinViewModel) {
        navigationController.popViewController(animated: true)
    }
    
    func navigateToCreatePin() {
        navigationController.pushViewController(createPinViewController, animated: true)
    }
}
