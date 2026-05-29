//
//  FeedbackCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 28/05/2026.
//

import CoreKit
import UIKit
import VaultCore

protocol FeedbackCoordinatorDelegate: AnyObject {
    func coordinatorDidFinish(_ coordinator: FeedbackCoordinator);
}

final class FeedbackCoordinator: BaseCoordinator {
    
    weak var delegate: FeedbackCoordinatorDelegate?
    
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
    
    override func start() {
        rootViewController = viewController
        navigationController.viewControllers = [ viewController ]
    }
    
    override func finish() {
        removeAllChildCoordinators()
        delegate?.coordinatorDidFinish(self)
    }
    
    lazy var viewController: FeedbackFormViewController = {
        let viewModel = FeedbackFormViewModel(feedbackUseCase: dependencies.getCreateFeedbackUseCase())
        
        viewModel.delegate = self
        
        let viewController = FeedbackFormViewController(viewModel: viewModel)
        
        return viewController
    }()
}

extension FeedbackCoordinator: FeedbackFormViewModelDelegate {
    func didTapClose(_ viewModel: FeedbackFormViewModel) {
        finish()
    }
}
