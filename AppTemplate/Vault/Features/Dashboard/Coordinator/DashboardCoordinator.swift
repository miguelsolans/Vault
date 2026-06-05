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
    
    weak var delegate: DashboardCoordinatorDelegate?
    
    // MARK: - Dependencies
    let navigationController: UINavigationController
    
    private let dependencies: DependenciesContainer
    
    private let vault: VaultDTO
    
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
    
    lazy var marketingViewController: MarketingViewController = {
        let configuration = MarketingConfiguration(
            pageTitle: "",
            pageSubtitle: "",
            primaryAction: .init(title: "Ok", action: .dismiss),
            items: [
                .init(imageName: "feedback_shake_device", title: "Shake for feedback", subtitle: "Shake your device to provide feedback, either suggestions or report a bug.")
            ]
        )
        
        let viewModel = dependencies.getMarketingViewModel(configuration: configuration)
        
        viewModel.delegate = self
        
        let viewController = MarketingViewController(viewModel: viewModel)
        
        return viewController
    }()
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
    
    func didTapFeedback(_ viewModel: DashboardViewModel) {
        
        let filter = OperationsFilter(
            reimbursementStatus: .expected,
            vault: vault
        )
        
        let coordinator = OperationsCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            filter: filter,
            navigationMode: .push(animated: true, hidesBottomBarWhenPushed: true),
            canAddOperation: false,
            canFilter: false
        )
        
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func didTapCustomize(_ viewModel: DashboardViewModel) {
        navigateToCustomizeDashboard(with: viewModel.vault)
    }
    
    func presentMarketing(_ viewModel: DashboardViewModel) {
        marketingViewController.modalPresentationStyle = .pageSheet
        
        navigationController.present(marketingViewController, animated: true) {
            
        }
    }
}

extension DashboardCoordinator: CustomizeDashboardCoordinatorDelegate {
    
    func coordinatorDidFinish(_ coordinator: CustomizeDashboardCoordinator) {
        
        removeChildCoordinator(coordinator)
        navigationController.dismiss(animated: true)
    }
    
    func navigateToCustomizeDashboard(with vault: VaultDTO) {
        
        let coordinator = CustomizeDashboardCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            vault: vault
        )
        
        coordinator.delegate = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
}

extension DashboardCoordinator: MarketingViewModelDelegate {
    
    func didTapPrimaryAction(_ viewModel: MarketingViewModel, action: MarketingAction) {
        if action == .dismiss {
            dependencies.getUserDefaultsManager()
                .feedbackDismissed = true
            
            marketingViewController.dismiss(animated: true, completion: nil)
        }
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

