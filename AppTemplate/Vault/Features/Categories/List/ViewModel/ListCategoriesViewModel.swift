//
//  ListCategoriesViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 01/04/2026.
//

import Foundation
import AppUIKit
import VaultCore

protocol ListCategoriesViewModelProtocol: AnyObject {
    func listCategoriesDidTapAddCategory(to vault: VaultDTO)
    func listCategoriesDidTapEditCategory(_ category: CategoryDTO)
}

final class ListCategoriesViewModel: NSObject {
    
    weak var delegate: ListCategoriesViewModelProtocol?
    
    // MARK: - Dependencies

    private let listUseCase: ListCategoriesUseCase
    
    private let deleteUseCase: DeleteCategoryUseCase
    
    private var vault: VaultDTO

    init(listUseCase: ListCategoriesUseCase, deleteUseCase: DeleteCategoryUseCase, vault: VaultDTO) {
        self.listUseCase = listUseCase
        self.deleteUseCase = deleteUseCase
        self.vault = vault
        super.init()
    }

    // MARK: - State
    
    private(set) var categoriesCell: [CategoryTableViewModel] = [] {
        didSet {
            updateUI?()
        }
    }
    
    private(set) var categories: [CategoryDTO] = [] {
        didSet {
            updateUI?()
        }
    }
    
    public var subtitle: String { vault.name }

    var numberOfRows: Int {
        categoriesCell.count
    }

    func category(at indexPath: IndexPath) -> CategoryTableViewModel {
        categoriesCell[indexPath.row]
    }

    func titleForCategory(at indexPath: IndexPath) -> String {
        category(at: indexPath).title
    }

    func subtitleForCategory(at indexPath: IndexPath) -> String {
        category(at: indexPath).subtitle
    }
    
    // MARK: - Bindings
    
    var updateUI: (() -> Void)?
}

// MARK: - Actions
extension ListCategoriesViewModel {
    func didTapAddCategory() {
        
        delegate?.listCategoriesDidTapAddCategory(to: vault)
    }
}

// MARK: - Data
extension ListCategoriesViewModel {
    
    func getData() {
        
        do {
            let request = ListCategoriesRequest(vaultID: vault.id)
            
            let response = try listUseCase.execute(request)
            
            self.categories = response.categories
            
            categoriesCell = makeListViewModel(with: categories)
            
        } catch {
            // TODO: Present error?
        }
    }

    func deleteCategory(at indexPath: IndexPath) {
        let category = categories[indexPath.row]
        
        do {
            let request = DeleteCategoryRequest(id: category.id)
            
            let _ = try deleteUseCase.execute(request)
            
            getData()
        } catch {
            // TODO: Present error?
        }
    }

    func editCategory(at indexPath: IndexPath) {
        let category = categories[indexPath.row]
        delegate?.listCategoriesDidTapEditCategory(category)
    }
}


extension ListCategoriesViewModel {
    fileprivate func makeListViewModel(with categories: [CategoryDTO]) -> [CategoryTableViewModel] {
        return categories.map { category in
            return CategoryTableViewModel(
                color: category.color,
                emoji: category.emoji,
                title: category.title,
                subtitle: category.operationType == .income ? "Income" : "Expense",
                canDelete: !category.hasOperations
            )
        }
    }
}


