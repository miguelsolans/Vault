//
//  ListOperationsViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 30/03/2026.
//

import UIKit
import Foundation
import CoreData
import VaultCore

protocol ListOperationsViewModelProtocol: AnyObject {
    func listOperationsDidTapAddOperation(of type: OperationType?, to vault: VaultDTO);
    func listOperationsDidTapEditOperation(_ operation: OperationDTO, in vault: VaultDTO)
    func listOperationsDidTapAddFromCamera(_ viewModel: ListOperationsViewModel)
    func listOperationsDidSelectOperation(_ operation: OperationDTO)
}

public final class ListOperationsViewModel: NSObject {
    
    weak var delegate: ListOperationsViewModelProtocol?
    
    // MARK: - Dependencies
    
    private(set) var filter: OperationsFilter
    
    private(set) var canAddOperation: Bool
    
    private(set) var canFilter: Bool
    
    private let listUseCase: ListOperationsByDayUseCase
    
    private let deleteUseCase: DeleteOperationUseCase
    
    private var foundationModelManager: FoundationModelAvailability
    
    init(
        filter: OperationsFilter,
        listUseCase: ListOperationsByDayUseCase,
        deleteUseCase: DeleteOperationUseCase,
        foundationModelManager: FoundationModelAvailability,
        canAddOperation: Bool,
        canFilter: Bool
    ) {
        self.filter = filter
        self.listUseCase = listUseCase
        self.deleteUseCase = deleteUseCase
        self.foundationModelManager = foundationModelManager
        self.canAddOperation = canAddOperation
        self.canFilter = canFilter
        super.init()
        setupBindings()
    }
    
    // MARK: - UI State
    
    public var title: String { L10n.Operations.pageTitle }
    
    public var subtitle: String { filter.vault.name }
    
    lazy var monthSelectorViewModel: MonthSelectorViewModel = {
        let viewModel = MonthSelectorViewModel();
        
        return viewModel
    }();
    
    public var isAddFromCameraAvailable: Bool {
        get {
            return self.foundationModelManager.isSupported
        }
    }
    
    private var operations: [OperationsTableViewModel] = []
    
    private var groupedOperations: [GroupedOperationsDTO] = []
    
    public var numberOfSections: Int { operations.count }
    
    public func numberOfRows(at index: Int) -> Int { operations[index].items.count }
    
    public func cellViewModel(at indexPath: IndexPath) -> OperationTableViewModel { operations[indexPath.section].items[indexPath.row] }
    
    public func headerViewModel(at index: Int) -> OperationSectionHeaderViewModel { operations[index].section }
    
    // MARK: - Bindings
    public var updateUI: (() -> Void)?
    
    public var onError: ((String) -> Void)?
}

// MARK: - Get Data -

extension ListOperationsViewModel {
    
    func getData() {
        
        self.operations = []
        
        self.groupedOperations = []
        
        do {
            self.operations = try loadGroupedOperations()
            
        } catch {
            onError?(L10n.Operations.errorFetchingOperations)
        }
        
        updateUI?()
    }
    
    fileprivate func deleteOperation(at indexPath: IndexPath) {
        let operation = groupedOperations[indexPath.section].operations[indexPath.row]

        do {
            let request = DeleteOperationRequest(id: operation.id)
            
            let _ = try deleteUseCase.execute(request)
            
            getData()
        } catch {
            onError?(L10n.Operations.errorDeletingOperation)
        }
    }
    
    fileprivate func loadGroupedOperations() throws -> [OperationsTableViewModel] {
        let request = ListOperationsByDayRequest(
            vaultID: filter.vault.id,
            startDate: filter.startDate,
            endDate: filter.endDate,
            operationType: filter.type,
            reimbursementStatus: filter.reimbursementStatus
        )
        
        let response = try listUseCase.execute(request)
        
        self.groupedOperations = response.groupedOperations
        
        operations = groupedOperations.map { group in
            
            let sectionViewModel = OperationSectionHeaderViewModel(
                date: group.date,
                amount: group.operations.reduce(0) { $0 + $1.netAmount }
            )
            
            let operationViewModel = group.operations.map { item in
                let viewModel = OperationTableViewModel(
                    color: item.category.color,
                    emoji: item.category.emoji,
                    title: item.title,
                    subtitle: item.category.title,
                    amount: item.netAmount,
                    operationType: item.operationType,
                    numberOfReimbursements: item.numberOfReimbursements,
                    expectedReimbursements: item.numberOfExpectedReimbursements
                )
                
                return viewModel
            }
            
            return OperationsTableViewModel(section: sectionViewModel, items: operationViewModel)
        }
        
        return operations
    }
}

// MARK: - Actions -

extension ListOperationsViewModel {
    
    public func didTapAddOperation(of type: OperationType? = nil) {
        
        delegate?.listOperationsDidTapAddOperation(of: type, to: filter.vault)
    }

    public func didTapEditOperation(at indexPath: IndexPath) {
        let operation = groupedOperations[indexPath.section].operations[indexPath.row]
        delegate?.listOperationsDidTapEditOperation(operation, in: filter.vault)
    }

    public func didSelectOperation(at indexPath: IndexPath) {
        let operation = groupedOperations[indexPath.section].operations[indexPath.row]
        delegate?.listOperationsDidSelectOperation(operation)
    }
    
    public func didTapDeleteOperation(at indexPath: IndexPath) {
        deleteOperation(at: indexPath)
    }
    
    public func didTapAddFromCamera() {
        delegate?.listOperationsDidTapAddFromCamera(self)
    }
}

// MARK: - Bindings -

extension ListOperationsViewModel {
    private func setupBindings() {
        monthSelectorViewModel.onMonthChanged = { [weak self] _ in
            guard let self = self else { return }
            
            self.filter.startDate = self.monthSelectorViewModel.currentDate.monthStart()
            self.filter.endDate = self.monthSelectorViewModel.currentDate.monthEnd()
            
            self.getData()
        }
    }
}
