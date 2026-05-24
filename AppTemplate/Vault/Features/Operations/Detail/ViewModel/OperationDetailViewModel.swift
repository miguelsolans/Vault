//
//  OperationDetailViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 29/04/2026.
//

import Foundation
import CoreKit
import AppUIKit
import VaultCore

protocol OperationDetailViewModelDelegate: AnyObject {
    func didDeleteOperation(_ viewModel: OperationDetailViewModel)
    func didTapEditOperation(_ viewModel: OperationDetailViewModel)
    func didTapEditReimbursement(_ viewModel: OperationDetailViewModel, reimbursement: ReimbursementDTO)
}

final class OperationDetailViewModel: NSObject {
    
    weak var delegate: OperationDetailViewModelDelegate?
    
    // MARK: - Dependencies
    
    private(set) var operation: OperationDTO
    
    private let operationDetailUseCase: OperationDetailUseCase
    
    private let deleteOperationUseCase: DeleteOperationUseCase
    
    private let updateReimbursementUseCase: UpdateReimbursementStatusUseCase
    
    init(
        operation: OperationDTO,
        operationDetailUseCase: OperationDetailUseCase,
        deleteOperationUseCase: DeleteOperationUseCase,
        updateReimbursementUseCase: UpdateReimbursementStatusUseCase
    ) {
        self.operation = operation
        self.operationDetailUseCase = operationDetailUseCase
        self.deleteOperationUseCase = deleteOperationUseCase
        self.updateReimbursementUseCase = updateReimbursementUseCase
    }
    
    // MARK: - UI State
    
    public var title: String = ""
    
    public var subtitle: String = ""
    
    public var headerViewModel: OperationDetailHeaderViewModel {
        
        let viewModel = OperationDetailHeaderViewModel(
            emoji: operation.category.emoji,
            color: operation.category.color,
            title: operation.category.title,
            amount: operation.netAmount,
            date: operation.date,
            operationType: operation.operationType
        )
        
        return viewModel
    }
    
    private var sections: [Section] {
        var sections: [Section] = [
            .operationDetail(detailOperation)
        ]
        
        if !reimbursingOperations.isEmpty {
            sections.append(.reimbursements(reimbursingOperations))
            sections.append(.summary(summaryRows))
        }
        
        return sections
    }
    
    public var detailOperation: [SimpleDetailInfoRow] {
        [
            .init(title: "Type", value: operation.operationType.localized, systemImageName: nil),
            .init(title: "Notes", value: operation.title, systemImageName: nil)
        ]
    }
    
    public var reimbursingOperations: [OperationDetailReimbursementRow] {
        guard let reimbursements = reimbursements, !reimbursements.isEmpty else {
            return []
        }
        
        return reimbursements.map { reimbursement in
            OperationDetailReimbursementRow(reimbursement: reimbursement)
        }
    }
    
    public var summaryRows: [SimpleDetailInfoRow] {
        [
            .init(title: "Operation amount", value: currencyFormatter.string(from: operation.amount) ?? "", systemImageName: nil),
            .init(title: "Total reimbursed", value: currencyFormatter.string(from: operation.totalReimbursed) ?? "", systemImageName: nil),
            .init(title: "Remaining", value: currencyFormatter.string(from: operation.netAmount) ?? "", systemImageName: nil)
        ]
    }

    public var numberOfSections: Int {
        sections.count
    }
    
    public func titleForSection(_ section: Int) -> String? {
        sections[section].title
    }
    
    public func numberOfRows(at section: Int) -> Int {
        sections[section].numberOfRows
    }
    
    public func section(at index: Int) -> Section {
        sections[index]
    }
    
    public func row(at indexPath: IndexPath) -> Any {
        switch sections[indexPath.section] {
        case .operationDetail(let rows):
            return rows[indexPath.row]
            
        case .reimbursements(let rows):
            return rows[indexPath.row]
            
        case .summary(let rows):
            return rows[indexPath.row]
        }
    }
    
    public func title(for section: Int) -> String {
        return sections[section].title ?? ""
    }
    
    public var isActionAvailable: Bool {
        return canDeleteOperation || canEditOperation
    }
    
    public var canDeleteOperation: Bool {
        return true
    }
    
    public var canEditOperation: Bool {
        return true
    }
    
    public func isReimbursementStatusAvailable(_ status: ReimbursementStatus, for indexPath: IndexPath) -> Bool {
        
        guard let reimbursements = reimbursements, !reimbursements.isEmpty else {
            return false
        }
        
        let reimbursement = reimbursements[indexPath.row]
        
        return reimbursement.status != status
    }
    
    // MARK: - Data
    
    private var reimbursements: [ReimbursementDTO]?
    
    // MARK: - Formatters
    
    private var currencyFormatter: LocalizedDecimalFormatter {
        LocalizedDecimalFormatter(numberStyle: .currency)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    // MARK: - Bindings
    
    public var updateUI: (() -> Void)?
    
    public var onSuccess: ((ViewModelFeedback) -> Void)?
    
    public var onError: ((ViewModelFeedback) -> Void)?
}

// MARK: - Data

extension OperationDetailViewModel {
    
    public func getData() {
        
        let request = OperationDetailRequest(operationID: operation.id)
        
        do {
            let response = try operationDetailUseCase.execute(request)
            
            operation = response.operation
            
            reimbursements = response.reimbursements
            
            updateUI?()
            
        } catch {
            onError?(.showAlert(message: "There was an error fetching data"))
        }
        
    }
    
    private func updateReimbursementStatus(at indexPath: IndexPath, to status: ReimbursementStatus) {
        guard let reimbursements = reimbursements else { return }
        
        let reimbursement = reimbursements[indexPath.row]
        
        let request = UpdateReimbursementStatusRequest(id: reimbursement.id, status: status)
        
        do {
            _ = try updateReimbursementUseCase.execute(request)
            
            getData()
            
            onSuccess?(.silent)
            
        } catch {
            
            onError?(.showAlert(message: "There was an error updating the status of the Reimbursement. Try again."))
        }
    }
}


// MARK: - Actions

extension OperationDetailViewModel {
    
    public func didTapEdit() {
        delegate?.didTapEditOperation(self)
    }
    
    public func didTapDelete() {
        let request = DeleteOperationRequest(
            id: operation.id
        )
        
        do {
            _ = try deleteOperationUseCase.execute(request)
            
            onSuccess?(.silent)
            
            delegate?.didDeleteOperation(self)
        } catch {
            onError?(.showAlert(message: "There was an error deleting operation. Try again."))
        }
    }
    
    public func didTapEditReimbursement(at indexPath: IndexPath) {
        guard let reimbursements = reimbursements else { return }
        
        let reimbursement = reimbursements[indexPath.row]
        
        delegate?.didTapEditReimbursement(self, reimbursement: reimbursement)
    }
    
    public func didTapReceivedReimbursementStatus(at indexPath: IndexPath) {
        updateReimbursementStatus(at: indexPath, to: .received)
    }
    
    public func didTapCancelledReimbursementStatus(at indexPath: IndexPath) {
        updateReimbursementStatus(at: indexPath, to: .cancelled)
    }
    
    public func didTapExpectedReimbursementStatus(at indexPath: IndexPath) {
        updateReimbursementStatus(at: indexPath, to: .expected)
    }
}

enum Section {
    case operationDetail([SimpleDetailInfoRow])
    case reimbursements([OperationDetailReimbursementRow])
    case summary([SimpleDetailInfoRow])
    
    var title: String? {
        switch self {
        case .operationDetail:
            return "Operation detail"
        case .reimbursements:
            return "Reimbursements"
        case .summary:
            return "Summary"
        }
    }
    
    var numberOfRows: Int {
        switch self {
        case .operationDetail(let rows),
                .summary(let rows):
            return rows.count
            
        case .reimbursements(let rows):
            return rows.count
        }
    }
}

struct SimpleDetailInfoRow {
    let title: String
    
    let value: String
    
    let systemImageName: String?
}

struct OperationDetailReimbursementRow {
    
    private(set) var amount: Double
    
    private(set) var sourceVaultName: String
    
    private(set) var destinationVaultName: String
    
    private(set) var status: ReimbursementStatus
    
    private(set) var title: String
    
    public var tableViewModel: ReimbursementTableViewModel {
        get {
            return ReimbursementTableViewModel(
                status: status,
                title: title,
                amount: amount
            )
        }
    }
    
    init(reimbursement: ReimbursementDTO) {
        self.amount = reimbursement.amount
        self.sourceVaultName = reimbursement.sourceVault.name
        self.destinationVaultName = reimbursement.destinationVault.name
        self.status = reimbursement.status
        self.title = reimbursement.notes
    }
}
