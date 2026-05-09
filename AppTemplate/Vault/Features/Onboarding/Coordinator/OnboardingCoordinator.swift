//
//  OnboardingCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import CoreKit
import UIKit
import VaultCore

protocol OnboardingCoordinatorDelegate: AnyObject {
    func coordinatorDidFinish(_ coordinator: OnboardingCoordinator);
}

final class OnboardingCoordinator: BaseCoordinator {
    
    weak var delegate: OnboardingCoordinatorDelegate?
    
    // MARK: - Dependencies
    
    let navigationController: UINavigationController
    
    private let dependencies: DependenciesContainer
    
    init(navigationController: UINavigationController, dependencies: DependenciesContainer) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        super.init()
    }
    
    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = introViewController
        navigationController.viewControllers = [ introViewController ]
    }
    
    override func finish() {
        removeAllChildCoordinators()
        delegate?.coordinatorDidFinish(self)
    }
    
    // MARK: - ViewController's
    
    lazy var introViewController: IntroViewController = {
        let viewModel = dependencies.getIntroViewModel()
        
        viewModel.delegate = self
        
        let viewController = IntroViewController(viewModel: viewModel);
        
        return viewController;
    }();

    lazy var createVaultViewController: CreateVaultViewController = {
        
        let viewModel = self.dependencies.getCreateVaultViewModel()
        
        viewModel.delegate = self;
        
        let viewController = CreateVaultViewController(viewModel: viewModel)
        
        return viewController;
    }();
}

// MARK: - IntroViewModel delegates
extension OnboardingCoordinator: IntroViewModelProtocol {
    func introViewModelDidTapCreateVault(_ viewModel: IntroViewModel) {
        self.goToCreateVault()
    }
}

// MARK: - CreateVaultViewModel delegates
extension OnboardingCoordinator: CreateVaultViewModelDelegate {
    
    func didCreateVault(_ vault: VaultDTO, andFileURL fileURL: URL?) {
        
        finish()
        
        guard let fileURL = fileURL else {
            finish()
            return
        }
        
        goToImportOperations(with: vault, andFileURL: fileURL)
    }
    
    func didUpdateVault(_ vault: VaultDTO) {
        
    }
    
    func goToCreateVault() {
        
        let coordinator = CreateVaultCoordinator(
            navigationController: navigationController,
            dependencies: dependencies
        )
        
        coordinator.delegate = self
        
        self.addChildCoordinator(coordinator)
        
        coordinator.start()
    }
}

// MARK: - ImportOperationsCoordinator delegates
extension OnboardingCoordinator: ImportOperationsCoordinatorDelegate {
    
    func goToImportOperations(with vault: VaultDTO, andFileURL url: URL) {
        
        let coordinator = ImportOperationsCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            vault: vault,
            fileURL: url
        )
        
        coordinator.delegate = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func coordinatorDidFinish(_ coordinator: ImportOperationsCoordinator) {
        finish()
    }
}

extension OnboardingCoordinator: CreateVaultCoordinatorDelegate {
    
    func coordinatorDidFinish(_ coordinator: CreateVaultCoordinator) {
        delegate?.coordinatorDidFinish(self)
    }
}
