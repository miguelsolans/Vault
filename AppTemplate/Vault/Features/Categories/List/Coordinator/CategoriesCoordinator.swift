//
//  CategoriesCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 01/04/2026.
//

import Foundation
import UIKit
import CoreKit
import VaultCore

class CategoriesCoordinator: BaseCoordinator {

    // MARK: - Dependencies
    
    let navigationController: UINavigationController
    
    fileprivate let dependencies: DependenciesContainer
    
    fileprivate let vault: VaultDTO

    init(navigationController: UINavigationController, dependencies: DependenciesContainer, vault: VaultDTO) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.vault = vault
    }
    
    // MARK: - Lifecycles

    override func start() {
        rootViewController = tableViewController
        self.navigationController.viewControllers = [tableViewController]
    }

    override func finish() {
        removeAllChildCoordinators()
    }
    
    // MARK: - ViewController's

    lazy var tableViewController: ListCategoriesViewController = {
        
        let viewModel = self.dependencies.getListCategoriesViewModel(with: vault)
        
        viewModel.delegate = self
        
        let viewController = ListCategoriesViewController(viewModel: viewModel)

        return viewController
    }()
}

// MARK: - ListCategoriesViewModel delegates
extension CategoriesCoordinator: ListCategoriesViewModelProtocol {
    func listCategoriesDidTapAddCategory(to vault: VaultDTO) {
        goToAddCategoryWithVault(vault)
    }
    
    func listCategoriesDidTapEditCategory(_ category: CategoryDTO) {
        goToEditCategoryWithCategory(category)
    }

    func goToAddCategoryWithVault(_ vault: VaultDTO) {
        let viewModel = dependencies.getAddCategoryViewModel(with: vault)

        viewModel.delegate = self

        let viewController = CategoryFormViewController(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
    }

    func goToEditCategoryWithCategory(_ category: CategoryDTO) {
        
        let viewModel = dependencies.getAddCategoryViewModel(with: vault, categoryToEdit: category)

        viewModel.delegate = self

        let viewController = CategoryFormViewController(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - AddCategoryViewModel delegates
extension CategoriesCoordinator: CategoryFormViewModelDelegate {
    
    func didAddCategory(_ viewModel: CategoryFormViewModel) {
        navigationController.popViewController(animated: true)
    }
    
    func didUpdateCategory(_ viewModel: CategoryFormViewModel) {
        navigationController.popViewController(animated: true)
    }
}
