//
//  ListCategoriesViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 01/04/2026.
//

import Foundation
import AppUIKit
import VaultCore

protocol ListCategoriesViewModelDelegate: AnyObject {
    func didTapAddCategory(_ viewModel: ListCategoriesViewModel)
    func didTapEditCategory(_ viewModel: ListCategoriesViewModel, category: CategoryDTO)
    func didTapCategory(_ viewModel: ListCategoriesViewModel, category: CategoryDTO)
}

final class ListCategoriesViewModel: NSObject {
    
    weak var delegate: ListCategoriesViewModelDelegate?
    
    // MARK: - Dependencies

    private let listUseCase: ListCategoriesUseCase
    
    private let deleteUseCase: DeleteCategoryUseCase
    
    private(set) var vault: VaultDTO

    init(
        listUseCase: ListCategoriesUseCase,
        deleteUseCase: DeleteCategoryUseCase,
        vault: VaultDTO
    ) {
        self.listUseCase = listUseCase
        self.deleteUseCase = deleteUseCase
        self.vault = vault
        super.init()
    }
    
    // MARK: - Data state
    
    private var categories: [CategoryDTO] = [] {
        didSet {
            updateUI?()
        }
    }
    
    private var categoriesCell: [CategoryTableViewModel] = [] {
        didSet {
            updateUI?()
        }
    }

    // MARK: - UI State
    
    public var sort: ListOrdering = .ascending {
        didSet {
            getData()
        }
    }
    
    public var title: String { L10n.Categories.pageTitle }
    
    public var subtitle: String { vault.name }
    
    public var numberOfRows: Int {
        categoriesCell.count
    }

    public func category(at indexPath: IndexPath) -> CategoryTableViewModel {
        categoriesCell[indexPath.row]
    }

    public func titleForCategory(at indexPath: IndexPath) -> String {
        category(at: indexPath).title
    }

    public func subtitleForCategory(at indexPath: IndexPath) -> String {
        category(at: indexPath).subtitle
    }
    
    // MARK: - Bindings
    
    public var updateUI: (() -> Void)?
    
    public var onErrorAlert: ((String) -> Void)?
}

// MARK: - Data -
extension ListCategoriesViewModel {
    
    func getData() {
        
        do {
            let request = ListCategoriesRequest(vaultID: vault.id, order: sort)
            
            let response = try listUseCase.execute(request)
            
            self.categories = response.categories
            
            categoriesCell = makeListViewModel(with: categories)
            
        } catch {
            onErrorAlert?(L10n.Categories.errorFetchingCategories)
        }
    }

    func deleteCategory(at indexPath: IndexPath) {
        let category = categories[indexPath.row]
        
        do {
            let request = DeleteCategoryRequest(id: category.id)
            
            let _ = try deleteUseCase.execute(request)
            
            getData()
        } catch {
            onErrorAlert?(L10n.Categories.errorDeletingCategory)
        }
    }

    func editCategory(at indexPath: IndexPath) {
        let category = categories[indexPath.row]
        
        delegate?.didTapEditCategory(self, category: category)
    }
}

// MARK: - Actions -
extension ListCategoriesViewModel {
    func didTapAddCategory() {
        
        delegate?.didTapAddCategory(self)
    }
    
    func didTapCategory(at index: IndexPath) {
        let category = categories[index.row]
        
        delegate?.didTapCategory(self, category: category)
    }
}

// MARK: - Helpers -
extension ListCategoriesViewModel {
    fileprivate func makeListViewModel(with categories: [CategoryDTO]) -> [CategoryTableViewModel] {
        return categories.map { category in
            
            let typeLocalized = category.operationType.localized
            let numberOfOperations = String(format: L10n.Categories.numberOfOperations, typeLocalized, category.numberOfOperations)
            
            let subtitleText = category.numberOfOperations == 0
                ? typeLocalized
                : numberOfOperations
            
            return CategoryTableViewModel(
                color: category.color,
                emoji: category.emoji,
                title: category.title,
                subtitle: subtitleText,
                canDelete: !category.hasOperations
            )
        }
    }
}


