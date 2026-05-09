//
//  AppCoordinator+Login.swift
//  Vault
//
//  Created by Miguel Solans on 04/04/2026.
//

import UIKit
import CoreKit

extension AppCoordinator: LoginCoordinatorDelegate {
    
    func navigateToLogin() {
        self.setRoot(setupLoginCoordinator().navigationController)
    }
    
    func setupLoginCoordinator() -> LoginCoordinator {
        
        let navigationController = UINavigationController()
        
        let coordinator = LoginCoordinator(navigationController: navigationController, dependencies: self.dependencies)
        
        coordinator.delegate = self
        
        coordinator.start()
        
        addChildCoordinator(coordinator)
        
        return coordinator
    }
    
    func loginCoordinatorDidAuthenticate(_ coordinator: LoginCoordinator) {
        
        isAuthenticated = true
        
        navigateToInitialPage()
    }
}
