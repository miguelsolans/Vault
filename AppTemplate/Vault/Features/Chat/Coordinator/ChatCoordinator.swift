//
//  ChatCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 15/04/2026.
//

import UIKit
import CoreKit

protocol ChatCoordinatorDelegate: AnyObject {
    func coordinatorDidFinish(_ coordinator: ChatCoordinator);
}

class ChatCoordinator: BaseCoordinator {
    
    weak var delegate: ChatCoordinatorDelegate?
    
    // MARK: - Dependencies
    let navigationController: UINavigationController
    
    fileprivate let dependencies: DependenciesContainer
    
    init(navigationController: UINavigationController, dependencies: DependenciesContainer) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Lifecycle
    
    override func start() {
        rootViewController = chatViewController
        navigationController.pushViewController(chatViewController, animated: true)
    }
    
    override func finish() {
        removeAllChildCoordinators()
        navigationController.popViewController(animated: true)
    }
    
    
    // MARK: - VC
    lazy var chatViewController: ChatViewController = {
        let viewModel = dependencies.createAgentViewModel()
        
        let viewController = ChatViewController(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        
        return viewController
    }()
}
