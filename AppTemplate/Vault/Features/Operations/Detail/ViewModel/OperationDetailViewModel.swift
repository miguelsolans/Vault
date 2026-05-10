//
//  OperationDetailViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 29/04/2026.
//

import Foundation
import AppUIKit
import VaultCore

protocol OperationDetailViewModelDelegate: AnyObject {
    func viewModelDidDeleteOperation(_ viewModel: OperationDetailViewModel)
    func viewModelDidTapEdit(_ viewModel: OperationDetailViewModel)
    func viewModelDidTapEditReimbursement(_ viewModel: OperationDetailViewModel, reimbursement: ReimbursementDTO)
}

final class OperationDetailViewModel {
    
    weak var delegate: OperationDetailViewModelDelegate?
    
    // MARK: - Dependencies
    
    private(set) var operation: OperationDTO
    
    private let deleteOperationUseCase: DeleteOperationUseCase
    
    init(
        operation: OperationDTO,
        deleteOperationUseCase: DeleteOperationUseCase
    ) {
        self.operation = operation
        self.deleteOperationUseCase = deleteOperationUseCase
    }
    
    // MARK: - Table Model
    
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
    
    private var sections: [Section] {
        var sections: [Section] = [
            .operationDetail(detailOperation)
        ]
        
        if !reimbursingOperations.isEmpty {
            sections.append(.reimbursements(reimbursingOperations))
        }
        
        sections.append(.summary(summaryRows))
        
        return sections
    }
    
    // MARK: - State
    
    var detailOperation: [SimpleDetailInfoRow] {
        [
            .init(title: "Type", value: operation.operationType.localized, systemImageName: nil),
            .init(title: "Notes", value: operation.title, systemImageName: nil)
        ]
    }
    
    var reimbursingOperations: [OperationDetailReimbursementRow] {
        reimbursements.map { reimbursement in
            OperationDetailReimbursementRow(reimbursement: reimbursement)
        }
    }
    
    var summaryRows: [SimpleDetailInfoRow] {
        [
            .init(title: "Operation amount", value: currencyFormatter.string(from: operation.amount) ?? "", systemImageName: nil),
            .init(title: "Total reimbursed", value: currencyFormatter.string(from: operation.totalReimbursed) ?? "", systemImageName: nil),
            .init(title: "Remaining", value: currencyFormatter.string(from: operation.netAmount) ?? "", systemImageName: nil)
        ]
    }
    
    // MARK: - UI
    
    var title: String = ""

    var headerViewModel: OperationDetailHeaderViewModel {
        OperationDetailHeaderViewModel(
            emoji: operation.category.emoji,
            color: operation.category.color,
            title: operation.category.title,
            amount: operation.netAmount,
            date: operation.date,
            operationType: operation.operationType
        )
    }
    
    var numberOfSections: Int {
        sections.count
    }
    
    func titleForSection(_ section: Int) -> String? {
        sections[section].title
    }
    
    func numberOfRows(at section: Int) -> Int {
        sections[section].numberOfRows
    }
    
    func section(at index: Int) -> Section {
        sections[index]
    }
    
    func row(at indexPath: IndexPath) -> Any {
        switch sections[indexPath.section] {
        case .operationDetail(let rows):
            return rows[indexPath.row]
            
        case .reimbursements(let rows):
            return rows[indexPath.row]
            
        case .summary(let rows):
            return rows[indexPath.row]
        }
    }
    
    func title(for section: Int) -> String {
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
    
    // MARK: - Private
    
    private var reimbursements: [ReimbursementDTO] {
        operation.reimbursements ?? []
    }
    
    private var currencyFormatter: LocalizedDecimalFormatter {
        LocalizedDecimalFormatter(numberStyle: .currency)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

extension OperationDetailViewModel {
    
    func didTapEdit() {
        delegate?.viewModelDidTapEdit(self)
    }
    
    func didTapDelete() {
        let request = DeleteOperationRequest(
            id: operation.id
        )
        
        do {
            _ = try deleteOperationUseCase.execute(request)
            
            delegate?.viewModelDidDeleteOperation(self)
        } catch {
            
        }
    }
    
    func didTapEditReimbursement(at indexPath: IndexPath) {
        let reimbursement = reimbursements[indexPath.row]
        
        delegate?.viewModelDidTapEditReimbursement(self, reimbursement: reimbursement)
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
