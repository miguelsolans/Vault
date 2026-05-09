//
//  CashflowBreakdownCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 08/05/2026.
//

import UIKit
import CoreKit

final class CashflowBreakdownCoordinator: BaseCoordinator {
    
    weak var delegate: DashboardCoordinatorDelegate?
    
    // MARK: - Dependencies
    let navigationController: UINavigationController
    
    private let dependencies: DependenciesContainer
    
    private let filter: OperationsFilter
    
    init(
        navigationController: UINavigationController,
        dependencies: DependenciesContainer,
        filter: OperationsFilter
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.filter = filter
    }
    
    // MARK: - Lifecycle
    
    override func start() {
        rootViewController = viewController
        navigationController.pushViewController(viewController, animated: true)
    }
    
    override func finish() {
        removeAllChildCoordinators()
        navigationController.popViewController(animated: true)
    }
    
    lazy var viewController: CashflowBreakdownViewController = {
        
        let viewModel = dependencies.getCashflowBreakdownViewModel(filter: filter)
        
        let viewController = CashflowBreakdownViewController(viewModel: viewModel)
        
        return viewController
    }()
    
}
