//
//  LoginCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 04/04/2026.
//

import UIKit
import CoreKit

protocol LoginCoordinatorDelegate: AnyObject {
    func loginCoordinatorDidAuthenticate(_ coordinator: LoginCoordinator)
}

final class LoginCoordinator: BaseCoordinator {
    
    weak var delegate: LoginCoordinatorDelegate?
    
    // MARK: - Dependencies
    
    let navigationController: UINavigationController
    
    private let dependencies: DependenciesContainer
    
    
    init(navigationController: UINavigationController, dependencies: DependenciesContainer) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = loginViewController
        navigationController.viewControllers = [ loginViewController ]
    }
    
    override func finish() {
        removeAllChildCoordinators()
    }
    
    // MARK: - Login VC & VM
    
    lazy var loginViewController: LoginViewController = {
        let viewModel = dependencies.getLoginViewModel()
        
        viewModel.delegate = self
        
        let viewController = LoginViewController(viewModel: viewModel)
        
        return viewController
    }();
    
}

// MARK: - Navigation

extension LoginCoordinator {
    func navigateToPin() {
        let coordinator = LoginPinCoordinator(navigationController: navigationController, dependencies: self.dependencies);
        
        coordinator.delegate = self
        
        coordinator.start()
        
        addChildCoordinator(coordinator)
    }
    
    func navigateToBiometric() {
        
    }
}

// MARK: - LoginViewModel delegates

extension LoginCoordinator: LoginViewModelDelegate {
    func didTapLogin(with type: LoginType) {
        
        switch type {
        case .pin:
            navigateToPin()
        case .biometric:
            navigateToBiometric()
        }
    }
}

// MARK: - LoginPinCoordinator delegates

extension LoginCoordinator: LoginPinCoordinatorDelegate {
    func loginPinCoordinatorDidAuthenticate(_ coordinator: LoginPinCoordinator) {
        
        delegate?.loginCoordinatorDidAuthenticate(self)
    }
}
