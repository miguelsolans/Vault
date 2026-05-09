//
//  OCRCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 17/04/2026.
//

import UIKit
import CoreKit

protocol OCRCoordinatorDelegate: AnyObject {
    func coordinatorDidFinish(_ coordinator: OCRCoordinator)
    func coordinatorDidFinish(_ coordinator: OCRCoordinator, with text: String)
}

class OCRCoordinator: BaseCoordinator {
    
    weak var delegate: OCRCoordinatorDelegate?

    // MARK: - Dependencies
    
    let navigationController: UINavigationController
    
    private let dependencies: DependenciesContainer
    
    init(navigationController: UINavigationController, dependencies: DependenciesContainer) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = viewController
        
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    override func finish() {
        removeAllChildCoordinators()
        navigationController.popViewController(animated: true)
    }
    
    // MARK: - VC
    lazy var viewController: OCRViewController = {
        let viewModel = dependencies.getOCRViewModel()
        viewModel.delegate = self

        let viewController = OCRViewController(viewModel: viewModel)
        return viewController
    }()
    
}

extension OCRCoordinator: OCRViewModelDelegate {
    
    func didDismissCamera(_ viewModel: OCRViewModel) {
        delegate?.coordinatorDidFinish(self)
        finish()
    }
    
    func didParseTextFromImage(text: String) {
        delegate?.coordinatorDidFinish(self, with: text)
        finish()
    }
}
