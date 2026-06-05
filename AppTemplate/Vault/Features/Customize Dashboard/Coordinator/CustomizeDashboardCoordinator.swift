//
//  CustomizeDashboardCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 04/06/2026.
//

import UIKit
import CoreKit
import VaultCore

protocol CustomizeDashboardCoordinatorDelegate: AnyObject {
    func coordinatorDidFinish(_ coordinator: CustomizeDashboardCoordinator)
}

final class CustomizeDashboardCoordinator: BaseCoordinator {
    
    weak var delegate: CustomizeDashboardCoordinatorDelegate?
    
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
        rootViewController = customizeViewController
        navigationController.pushViewController(customizeViewController, animated: true)
    }
    
    override func finish() {
        removeAllChildCoordinators()
        navigationController.popViewController(animated: true)
    }
    
    // MARK: - ViewController's
    
    lazy var customizeViewController: CustomizeDashboardViewController = {
        let viewModel = dependencies.getCustomizeDashboardViewModel(
            vault: vault
        )
        
        let viewController = CustomizeDashboardViewController(
            viewModel: viewModel
        )
        
        viewController.hidesBottomBarWhenPushed = true
        
        return viewController
    }()
}
