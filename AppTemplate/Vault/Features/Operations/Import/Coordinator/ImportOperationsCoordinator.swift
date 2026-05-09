//
//  ImportOperationsCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 06/04/2026.
//

import CoreKit
import UIKit
import VaultCore

protocol ImportOperationsCoordinatorDelegate: AnyObject {
    func coordinatorDidFinish(_ coordinator: ImportOperationsCoordinator);
}

final class ImportOperationsCoordinator: BaseCoordinator {
    
    weak var delegate: ImportOperationsCoordinatorDelegate?

    // MARK: - Dependencies
    
    private let navigationController: UINavigationController
    
    private let dependencies: DependenciesContainer
    
    private let vault: VaultDTO
    
    private let fileURL: URL
    
    init(navigationController: UINavigationController, dependencies: DependenciesContainer, vault: VaultDTO, fileURL: URL) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.vault = vault
        self.fileURL = fileURL
    }
    
    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = importViewController
        importViewController.hidesBottomBarWhenPushed = true
        importViewController.navigationItem.hidesBackButton = true
        navigationController.pushViewController(importViewController, animated: true)
    }
    
    override func finish() {
        removeAllChildCoordinators()
        delegate?.coordinatorDidFinish(self)
    }
    
    // MARK: - ViewController's
    
    lazy var importViewController: ImportOperationsViewController = {
        let viewModel = dependencies.createImportOperationsViewModel(
            with: vault,
            andFileURL: fileURL
        )
        
        viewModel.delegate = self;
        
        return ImportOperationsViewController(viewModel: viewModel)
    }()
    
}

// MARK: - ImportOperationsViewModel delegates

extension ImportOperationsCoordinator: ImportOperationsViewModelDelegate {
    
    func viewModelDidImportOperations(_ viewModel: ImportOperationsViewModel) {
        finish()
    }
    
    func viewModelDidIgnoreImportOperations(_ viewModel: ImportOperationsViewModel) {
        finish()
    }
}
