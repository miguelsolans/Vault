//
//  DashboardCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 01/04/2026.
//

import CoreKit
import UIKit
import VaultCore

protocol DashboardCoordinatorDelegate: AnyObject {
    func coordinator(_ coordinator: DashboardCoordinator, didSelectVault vault: VaultDTO)
}

class DashboardCoordinator: BaseCoordinator {
    
    // MARK: - Dependencies
    let navigationController: UINavigationController
    
    fileprivate let dependencies: DependenciesContainer
    
    fileprivate let vault: VaultDTO
    
    weak var delegate: DashboardCoordinatorDelegate?
    
    init(
        navigationController: UINavigationController,
        dependencies: DependenciesContainer,
        vault: VaultDTO
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.vault = vault
    }
    
    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = dashboardViewController
        self.navigationController.delegate = self
        self.navigationController.viewControllers = [ dashboardViewController ];
    }
    
    override func finish() {
        removeAllChildCoordinators()
    }
    
    // MARK: - ViewController's
    
    lazy var dashboardViewController: DashboardViewController = {
        
        let filter = OperationsFilter(
            startDate: Date().monthStart(),
            endDate: Date().monthEnd(),
            period: .monthly,
            vault: vault
        )
        
        let viewModel = self.dependencies.getDashboardViewModel(with: vault, filter: filter)
        
        viewModel.delegate = self
        
        let viewController = DashboardViewController(viewModel: viewModel)
        
        return viewController;
    }();
}

// MARK: - ListVaultCoordinatorDelegate
extension DashboardCoordinator: ListVaultCoordinatorDelegate {
    
    func coordinatorDidFinish(_ coordinator: ListVaultCoordinator) {
        removeChildCoordinator(coordinator)
        navigationController.dismiss(animated: true)
    }
    
    func coordinator(_ coordinator: ListVaultCoordinator, didSelectVault vault: VaultDTO) {
        removeChildCoordinator(coordinator)
        navigationController.dismiss(animated: true) { [weak self] in
            self?.delegate?.coordinator(self!, didSelectVault: vault)
        }
    }
}

// MARK: - DashboardViewControllerDelegate
extension DashboardCoordinator: DashboardViewModelDelegate {
    func didTapVaultSelector(_ viewModel: DashboardViewModel) {
        let navigation = UINavigationController()
        
        let coordinator = ListVaultCoordinator(navigationController: navigation, dependencies: dependencies, canManageVaults: false)
        
        coordinator.delegate = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
        
        navigation.modalPresentationStyle = .pageSheet
        navigationController.present(navigation, animated: true)
    }
    
    func didTapAgent(_ viewModel: DashboardViewModel) {
        
        let coordinator = ChatCoordinator(navigationController: navigationController, dependencies: dependencies)
        
        addChildCoordinator(coordinator)
        
        coordinator.delegate = self
        
        coordinator.start()
    }
    
    func didTapOperationGroup(_ viewModel: DashboardViewModel, with filter: OperationsFilter) {
        
        let coordinator = CashflowBreakdownCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            filter: filter
        )
        
        coordinator.start()
        
        addChildCoordinator(coordinator)
    }
}

extension DashboardCoordinator: ChatCoordinatorDelegate {
    
    func coordinatorDidFinish(_ coordinator: ChatCoordinator) {
        
        removeChildCoordinator(coordinator)
    }
}

extension DashboardCoordinator: UINavigationControllerDelegate {
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
