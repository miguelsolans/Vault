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

    init(
        navigationController: UINavigationController,
        dependencies: DependenciesContainer,
        vault: VaultDTO
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.vault = vault
    }
    
    // MARK: - Lifecycles

    override func start() {
        rootViewController = listViewController
        self.navigationController.viewControllers = [listViewController]
    }

    override func finish() {
        removeAllChildCoordinators()
    }
    
    // MARK: - ViewController's

    lazy var listViewController: ListCategoriesViewController = {
        
        let viewModel = self.dependencies.getListCategoriesViewModel(with: vault)
        
        viewModel.delegate = self
        
        let viewController = ListCategoriesViewController(viewModel: viewModel)

        return viewController
    }()
}

// MARK: - ListCategoriesViewModel delegates
extension CategoriesCoordinator: ListCategoriesViewModelDelegate {
    func didTapCategory(_ viewModel: ListCategoriesViewModel, category: CategoryDTO) {
        goToCategoryDetail(category)
    }
    
    func didTapAddCategory(_ viewModel: ListCategoriesViewModel) {
        goToAddCategoryWithVault(viewModel.vault)
    }
    
    func didTapEditCategory(_ viewModel: ListCategoriesViewModel, category: VaultCore.CategoryDTO) {
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

extension CategoriesCoordinator: CategoryDetailViewModelDelegate {
    
    private func goToCategoryDetail(_ category: CategoryDTO) {
        let viewModel = dependencies.getCategoryDetailViewModel(with: category)
        
        viewModel.delegate = self
        
        let viewController = CategoryDetailViewController(
            viewModel: viewModel
        )
        
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func didTapEditCategory(_ viewModel: CategoryDetailViewModel) {
        navigationController.popViewController(animated: true)
        
        goToEditCategoryWithCategory(viewModel.category)
    }
    
    func didDeleteCategory(_ viewModel: CategoryDetailViewModel) {
        navigationController.popViewController(animated: true)
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
