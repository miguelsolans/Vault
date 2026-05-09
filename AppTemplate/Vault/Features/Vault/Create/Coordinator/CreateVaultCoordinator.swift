//
//  CreateVaultCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 08/04/2026.
//

import UIKit
import CoreKit
import VaultCore

protocol CreateVaultCoordinatorDelegate: AnyObject {
    func coordinatorDidFinish(_ coordinator: CreateVaultCoordinator)
}

class CreateVaultCoordinator: BaseCoordinator {
    
    weak var delegate: CreateVaultCoordinatorDelegate?
    
    // MARK: - Dependencies
    let navigationController: UINavigationController
    
    fileprivate let dependencies: DependenciesContainer
    
    init(navigationController: UINavigationController, dependencies: DependenciesContainer) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = createViewController
        navigationController.pushViewController(createViewController, animated: true)
    }
    
    override func finish() {
        removeAllChildCoordinators()
        delegate?.coordinatorDidFinish(self)
    }
    
    // MARK: - ViewController's
    
    lazy var createViewController: CreateVaultViewController = {
        let viewModel = dependencies.getCreateVaultViewModel()
        
        viewModel.delegate = self
        
        let viewController = CreateVaultViewController(viewModel: viewModel)
        
        return viewController
    }()
}

extension CreateVaultCoordinator: CreateVaultViewModelDelegate {
    func didCreateVault(_ vault: VaultDTO, andFileURL fileURL: URL?) {
        
        guard let fileURL = fileURL else {
            finish()
            return
        }
        
        goToImportOperations(with: vault, andFileURL: fileURL)
    }
    
    func didUpdateVault(_ vault: VaultDTO) {
        finish()
    }
}

// MARK: - ImportOperationsCoordinator delegates
extension CreateVaultCoordinator: ImportOperationsCoordinatorDelegate {
    
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
