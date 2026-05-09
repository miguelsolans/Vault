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
    
    init(navigationController: UINavigationController, dependencies: DependenciesContainer) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        super.init()
    }
    
    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = sampleViewController
        self.navigationController.viewControllers = [sampleViewController];
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
