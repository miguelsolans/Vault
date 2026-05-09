//
//  AppCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 21/05/2024.
//

import UIKit
import CoreKit
import VaultCore

class AppCoordinator: BaseCoordinator  {
    
    // MARK: - Properties
    let window: UIWindow?
    
    let dependencies: DependenciesContainer
    
    var isAuthenticated: Bool = false

    // MARK: - Methods
    
    init(window: UIWindow?, dependencies: DependenciesContainer) {
        self.window = window
        self.dependencies = dependencies
    }
    
    override func start() {
        guard let window else { return }
        
        window.makeKeyAndVisible()
        
        navigateToInitialPage()
    }
    
    override func finish() {
        
        self.removeAllChildCoordinators()
    }
}

extension AppCoordinator {
    
    func navigateToInitialPage() {
        
        removeAllChildCoordinators()
        
        let userDefaults = dependencies.getUserDefaultsManager()
        
        guard let favoriteVault = userDefaults.favoriteVault,
              let vaultID = UUID(uuidString: favoriteVault) else {
            navigateToOnboarding()
            
            return
        }
        
        do {
            
            let request = GetVaultUseCaseRequest(id: vaultID)
            
            let useCase = dependencies.getVaultUseCase()
            
            let response = try useCase.execute(request)
            
            let requiresPinOnLaunch = userDefaults.requiresPinOnLaunch
            
            (requiresPinOnLaunch && !isAuthenticated) ? navigateToLogin() : navigateToPrivateArea(with: response.vault)
            
        } catch {
            navigateToOnboarding()
        }
    }
}

// MARK: - Utils

extension AppCoordinator {
    public func setRoot(
        _ viewController: UIViewController,
        animated: Bool = true
    ) {
        guard let window else { return }
        
        if animated {
            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: {
                    window.rootViewController = viewController
                }
            )
        } else {
            window.rootViewController = viewController
        }
    }
}
