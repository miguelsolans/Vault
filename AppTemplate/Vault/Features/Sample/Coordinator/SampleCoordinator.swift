//
//  SampleCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 30/03/2026.
//

import CoreKit
import UIKit

protocol SampleCoordinatorDelegate: AnyObject {
    // Declare SampleCoordinator delegate functions
    func coordinatorDidFinish(_ coordinator: SampleCoordinator)
}

class SampleCoordinator: BaseCoordinator {
    
    weak var delegate: SampleCoordinatorDelegate?
    
    // MARK: - Dependencies

    let navigationController: UINavigationController
    
    fileprivate let dependencies: DependenciesContainer
    
    private let navigationMode: CoordinatorNavigationMode
    
    init(
        navigationController: UINavigationController,
        dependencies: DependenciesContainer,
        navigationMode: CoordinatorNavigationMode = .root
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.navigationMode = navigationMode
        super.init()
    }
    
    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = sampleViewController
        
        if case .root = navigationMode {
            navigationController.delegate = self
        }
        
        navigationController.showInitialViewController(sampleViewController, using: navigationMode)
    }
    
    override func finish() {
        removeAllChildCoordinators()
        delegate?.coordinatorDidFinish(self)
    }
    
    // MARK: - ViewController's
    
    lazy var sampleViewController: SampleViewController = {
        let viewModel = dependencies.createSampleViewModel()
        
        viewModel.delegate = self
        
        let viewController = SampleViewController(viewModel: viewModel)
        
        return viewController;
    }();
    
}

extension SampleCoordinator: SampleViewModelDelegate {
    
}

extension SampleCoordinator: UINavigationControllerDelegate {
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
