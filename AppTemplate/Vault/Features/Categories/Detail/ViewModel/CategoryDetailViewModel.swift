//
//  CategoryDetailViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 10/05/2026.
//

import UIKit
import VaultCore

protocol CategoryDetailViewModelDelegate: AnyObject {
    func didTapEditCategory(_ viewModel: CategoryDetailViewModel)
    func didDeleteCategory(_ viewModel: CategoryDetailViewModel)
}

final class CategoryDetailViewModel: NSObject {
    
    weak var delegate: CategoryDetailViewModelDelegate?
    
    // MARK: - Dependencies
    
    private(set) var category: CategoryDTO
    
    private let deleteUseCase: DeleteCategoryUseCase
    
    init(
        deleteUseCase: DeleteCategoryUseCase,
        category: CategoryDTO
    ) {
        self.deleteUseCase = deleteUseCase
        self.category = category
    }
    
    // MARK: - UI State
    
    public var title: String {
        L10n.CategoryDetail.pageTitle
    }
    
    public var subtitle: String {
        L10n.CategoryDetail.pageSubtitle
    }
    
    public var canEdit: Bool {
        true
    }
    
    public var canDelete: Bool {
        !category.hasOperations
    }
    
    public var headerViewModel: OperationDetailHeaderViewModel {
        OperationDetailHeaderViewModel(
            emoji: category.emoji,
            color: category.color,
            title: category.title,
            amount: category.totalAmount,
            operationType: category.operationType
        )
    }
    
    public var numberOfRows: Int {
        detail.count
    }
    
    public func row(at indexPath: IndexPath) -> SimpleDetailInfoRow {
        return detail[indexPath.row]
    }
    
    // MARK: - Data State
    
    lazy private var detail: [SimpleDetailInfoRow] = {
        
        var detail: [SimpleDetailInfoRow] = []
        
        detail.append(
            .init(title: L10n.CategoryDetail.type, value: category.operationType.localized, systemImageName: nil)
        )
        
        if !category.notes.isEmpty {
            detail.append(
                .init(title: L10n.CategoryDetail.notes, value: category.notes, systemImageName: nil)
            )
        }
        
        if category.numberOfOperations > 0 {
            detail.append(
                .init(title: L10n.CategoryDetail.operationsCount, value: "\(category.numberOfOperations)", systemImageName: nil)
            )
        }
        
        return detail
    }()
    
    // MARK: - Bindings
    public var updateUI: (() -> Void)?
    
    public var onSuccess: (() -> Void)?
    
    public var onError: ((String) -> Void)?
    
}

extension CategoryDetailViewModel {
    
    private func delete() {
        let request = DeleteCategoryRequest(id: category.id)
        
        do {
            _ = try deleteUseCase.execute(request)
            
            onSuccess?()
            
            delegate?.didDeleteCategory(self)
        } catch {
            onError?(L10n.CategoryDetail.errorDeletingCategory)
        }
    }
}

extension CategoryDetailViewModel {
    public func didTapEdit() {
        delegate?.didTapEditCategory(self)
    }
    
    public func didTapDelete() {
        delete()
    }
}

struct CategoryDetailRow {
    let title: String
    
    let value: String
}
