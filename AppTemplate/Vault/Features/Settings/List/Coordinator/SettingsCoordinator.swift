//
//  SettingsCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 02/04/2026.
//

import UIKit
import CoreKit
import VaultCore

protocol SettingsCoordinatorDelegate: AnyObject {
    func coordinatorDidFinish(_ coordinator: SettingsCoordinator)
}

final class SettingsCoordinator: BaseCoordinator {
    
    weak var delegate: SettingsCoordinatorDelegate?
    
    // MARK: - Dependencies
    
    public let navigationController: UINavigationController
    
    private let dependencies: DependenciesContainer
    
    init(
        navigationController: UINavigationController,
        dependencies: DependenciesContainer
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = settingsViewController
        navigationController.delegate = self
        navigationController.viewControllers = [ settingsViewController ];
    }
    
    override func finish() {
        removeAllChildCoordinators()
        delegate?.coordinatorDidFinish(self)
    }
    
    // MARK: - ViewControllers's
    
    lazy var settingsViewController: SettingsViewController = {
        let viewModel = dependencies.getSettingsViewModel()
        
        viewModel.delegate = self
        
        let viewController = SettingsViewController(viewModel: viewModel)
        
        return viewController
    }()
}

// MARK: - Child coordinators

extension SettingsCoordinator {
    func setupSecurityCoordinator() -> SecurityCoordinator {
        let coordinator = SecurityCoordinator(navigationController: navigationController, dependencies: dependencies)
        
        coordinator.start()
        
        self.addChildCoordinator(coordinator)
        
        return coordinator
    }
    
    func setupVaultsCoordinator() -> ListVaultCoordinator {
        let coordinator = ListVaultCoordinator(navigationController: navigationController, dependencies: dependencies, canManageVaults: true)
        
        coordinator.delegate = self
        
        coordinator.start()
        
        self.addChildCoordinator(coordinator)
        
        return coordinator
    }
}

// MARK: - SettingsViewModel delegates
extension SettingsCoordinator: SettingsViewModelDelegate {
    func didSelectOption(_ viewModel: SettingsViewModel, option: SettingsOption) {
        if(option == .vaults) {
            _ = self.setupVaultsCoordinator()
        }
        
        if(option == .security){
            _ = self.setupSecurityCoordinator()
        }
    }
    
    func didDeleteAllData(_ viewModel: SettingsViewModel) {
        self.finish()
    }
}

// MARK: - ListVaultCoordinator delegates
extension SettingsCoordinator: ListVaultCoordinatorDelegate {
    
    func coordinatorDidFinish(_ coordinator: ListVaultCoordinator) {
        
        removeChildCoordinator(coordinator)
    }
    
    func coordinator(_ coordinator: ListVaultCoordinator, didSelectVault vault: VaultDTO) {
        
    }
}


extension SettingsCoordinator : UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == rootViewController {
            cleanUpFinishedCoordinators()
        }
    }
    
    private func cleanUpFinishedCoordinators() {
        removeFinishedChildren(from: self)
    }
    
    private func removeFinishedChildren(from coordinator: BaseCoordinator) {
        
        coordinator.removeAllChildCoordinators()
    }
}

