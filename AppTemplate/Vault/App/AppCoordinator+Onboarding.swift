//
//  AppCoordinator+Onboarding.swift
//  Vault
//
//  Created by Miguel Solans on 04/04/2026.
//

import UIKit
import CoreKit

extension AppCoordinator: OnboardingCoordinatorDelegate {
    
    func setupOnboardingCoordinator() -> OnboardingCoordinator {
        let navigationController = UINavigationController();
        
        let coordinator = OnboardingCoordinator(navigationController: navigationController, dependencies: self.dependencies)
        
        coordinator.delegate = self;
        
        self.addChildCoordinator(coordinator)
        
        coordinator.start()
        
        return coordinator;
    }
    
    func navigateToOnboarding() {
        
        self.setRoot(setupOnboardingCoordinator().navigationController)
    }
    
    func coordinatorDidFinish(_ coordinator: OnboardingCoordinator) {
        self.removeChildCoordinator(coordinator)
        
        isAuthenticated = true
        
        navigateToInitialPage()
        
        /*do {
            guard let vault = try VaultRepository().fetchFirstVault() else {
                goToOnboarding()
                
                return
            }
            
            self.goToPrivateArea(with: vault)
            
        } catch {
            // TODO: Present error?
        }*/
        
        
        
        
    }
}
