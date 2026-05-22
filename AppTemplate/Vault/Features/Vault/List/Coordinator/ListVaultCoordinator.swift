//
//  ListVaultCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 08/04/2026.
//

import UIKit
import CoreKit
import VaultCore

protocol ListVaultCoordinatorDelegate: AnyObject {
    func coordinatorDidFinish(_ coordinator: ListVaultCoordinator)
    func coordinator(_ coordinator: ListVaultCoordinator, didSelectVault vault: VaultDTO)
}

class ListVaultCoordinator: BaseCoordinator {
    
    weak var delegate: ListVaultCoordinatorDelegate?
    
    // MARK: - Dependencies
    let navigationController: UINavigationController
    
    fileprivate let dependencies: DependenciesContainer
    
    fileprivate let canManageVaults: Bool
    
    init(
        navigationController: UINavigationController,
        dependencies: DependenciesContainer,
        canManageVaults: Bool = false
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.canManageVaults = canManageVaults
    }
    
    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = listViewController
        navigationController.pushViewController(listViewController, animated: true)
    }
    
    override func finish() {
        removeAllChildCoordinators()
    }
    
    // MARK: - ViewController's
    
    lazy var listViewController: ListVaultViewController = {
        let viewModel = dependencies.createListVaultViewModel(canManageVaults: canManageVaults)
        
        viewModel.delegate = self
        
        let viewController = ListVaultViewController(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        
        return viewController
    }()
    
}

extension ListVaultCoordinator: ListVaultViewModelDelegate {
    
    func viewModelDidTapCreateVault(_ viewModel: ListVaultViewModel) {
        self.navigateToCreateVault()
    }
    
    func viewModel(_ viewModel: ListVaultViewModel, didSelectVault vault: VaultDTO) {
        delegate?.coordinator(self, didSelectVault: vault)
    }
    
    func viewModel(_ viewModel: ListVaultViewModel, didTapEditVault vault: VaultDTO) {
        navigateToEditVault(with: vault)
    }
    
    func viewModel(_ viewModel: ListVaultViewModel, didTapExportVault vault: VaultDTO, csvContent: String, suggestedFilename: String) {
        listViewController.presentExportFileDialog(csvContent: csvContent, suggestedFilename: suggestedFilename)
    }
    
    func navigateToEditVault(with vault: VaultDTO) {
        let viewModel = dependencies.getCreateVaultViewModel(vaultToEdit: vault)
        
        viewModel.delegate = self
        
        let viewController = VaultFormViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension ListVaultCoordinator: VaultFormViewModelDelegate {
    
    func navigateToCreateVault() {
        
        let coordinator = CreateVaultCoordinator(navigationController: navigationController, dependencies: dependencies)
        
        coordinator.delegate = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func didCreateVault(_ viewModel: VaultFormViewModel, vault: VaultCore.VaultDTO, with fileURL: URL?) {
        navigationController.popToViewController(listViewController, animated: true)
    }
    
    func didUpdateVault(_ viewModel: VaultFormViewModel, vault: VaultCore.VaultDTO) {
        navigationController.popToViewController(listViewController, animated: true)
    }
}

extension ListVaultCoordinator: CreateVaultCoordinatorDelegate {
    
    func coordinatorDidFinish(_ coordinator: CreateVaultCoordinator) {
        removeChildCoordinator(coordinator)
        navigationController.popToViewController(listViewController, animated: true)
    }
}
