//
//  LoginPinCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 04/04/2026.
//

import UIKit
import CoreKit

protocol LoginPinCoordinatorDelegate: AnyObject {
    func loginPinCoordinatorDidAuthenticate(_ coordinator: LoginPinCoordinator)
}

class LoginPinCoordinator: BaseCoordinator {
    
    weak var delegate: LoginPinCoordinatorDelegate?
    
    // MARK: - Dependencies
    
    let navigationController: UINavigationController
    
    let dependencies: DependenciesContainer
    
    init(navigationController: UINavigationController, dependencies: DependenciesContainer) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = pinViewController
        navigationController.pushViewController(pinViewController, animated: true)
    }
    
    override func finish() {
        removeAllChildCoordinators()
    }
    
    // MARK: - ViewController's
    
    lazy var pinViewController: PinViewController = {
        let viewModel = dependencies.getLoginPinViewModel()
        
        viewModel.delegate = self
        
        let viewController = PinViewController(viewModel: viewModel.pinViewModel);
        
        return viewController
    }()
}

// MARK: - LoginPinViewModel delegates

extension LoginPinCoordinator: LoginPinViewModelDelegate {
    func loginPinViewModelDidAuthenticate(_ viewModel: LoginPinViewModel) {
        delegate?.loginPinCoordinatorDidAuthenticate(self)
    }
}
