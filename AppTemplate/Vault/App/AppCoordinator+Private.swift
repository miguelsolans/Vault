//
//  AppCoordinator+Private.swift
//  Vault
//
//  Created by Miguel Solans on 04/04/2026.
//

import UIKit
import CoreKit
import VaultCore

extension AppCoordinator {
    
    func navigateToPrivateArea(with vault: VaultDTO) {
        
        let viewModel = dependencies.createTabBarViewModel()
        
        let tabBar = TabBar(viewModel: viewModel)
        
        let tabs = buildTabs(from: viewModel.tabs, with: vault);
        
        tabBar.setViewControllers(tabs, animated: false)
        
        self.setRoot(tabBar)
    }
    
    private func buildTabs(from tabs: [TabItem], with vault: VaultDTO) -> [UIViewController] {
        return tabs.map { tab in
            
            let navigationController: UINavigationController
            
            switch tab.type {
            case .dashboard:
                navigationController = self.setupDashboardCoordinator(for: vault).navigationController
            case .operations:
                navigationController = self.setupOperationsCoordinator(for: vault).navigationController
            case .tag:
                navigationController = self.setupCategoriesCoordinator(for: vault).navigationController
            case .settings:
                navigationController = self.setupSettingsCoordinator().navigationController
            case .demoUI:
                navigationController = self.setupSampleCoordinator().navigationController
            }
            
            navigationController.tabBarItem = UITabBarItem(title: tab.title,
                                                           image: UIImage(systemName: tab.imageName),
                                                           selectedImage: UIImage(systemName: tab.selectedImageName))
            
            return navigationController;
        }
    }
}

// MARK: - Dashboard

extension AppCoordinator {
    func setupDashboardCoordinator(for vault: VaultDTO) -> DashboardCoordinator {
        let navigationController = UINavigationController();
        
        let coordinator = DashboardCoordinator(navigationController: navigationController, dependencies: self.dependencies, vault: vault);
        
        coordinator.delegate = self
        self.addChildCoordinator(coordinator);
        
        coordinator.start()
        
        return coordinator;
    }
}

// MARK: - DashboardCoordinatorDelegate
extension AppCoordinator: DashboardCoordinatorDelegate {
    
    func coordinator(_ coordinator: DashboardCoordinator, didSelectVault vault: VaultDTO) {
        switchToVault(vault)
    }
    
    private func switchToVault(_ vault: VaultDTO) {
        navigateToPrivateArea(with: vault)
    }
}

// MARK: - Operations

extension AppCoordinator {
    
    func setupOperationsCoordinator(for vault: VaultDTO) -> OperationsCoordinator {
        let navigationController = UINavigationController();
        
        let coordinator = OperationsCoordinator(navigationController: navigationController, dependencies: self.dependencies, vault: vault);
        
        self.addChildCoordinator(coordinator);
        
        coordinator.start();
        
        return coordinator
    }
}

// MARK: - Categories

extension AppCoordinator {
    
    func setupCategoriesCoordinator(for vault: VaultDTO) -> CategoriesCoordinator {
        let navigationController = UINavigationController();
        
        let coordinator = CategoriesCoordinator(navigationController: navigationController, dependencies: dependencies, vault: vault);
        
        self.addChildCoordinator(coordinator);
        
        coordinator.start()
        
        return coordinator;
    }
}


// MARK: - Settings
extension AppCoordinator: SettingsCoordinatorDelegate {
    func setupSettingsCoordinator() -> SettingsCoordinator {
        let navigationController = UINavigationController();
        
        let coordinator = SettingsCoordinator(navigationController: navigationController, dependencies: dependencies)
        
        coordinator.delegate = self
        
        self.addChildCoordinator(coordinator)
        
        coordinator.start()
        
        return coordinator
    }
    
    func coordinatorDidFinish(_ coordinator: SettingsCoordinator) {
        self.removeAllChildCoordinators()
        
        navigateToInitialPage()
    }
}
