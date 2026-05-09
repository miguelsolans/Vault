//
//  AddOperationCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 30/04/2026.
//

import UIKit
import CoreKit
import VaultCore

final class AddOperationCoordinator: BaseCoordinator {
    
    // MARK: - Dependencies
    
    let navigationController: UINavigationController
    
    let dependencies: DependenciesContainer
    
    fileprivate let vault: VaultDTO
    
    fileprivate let operationToEdit: OperationDTO?
    
    fileprivate let operationType: OperationType?
    
    fileprivate let receipt: ReceiptOutput?
    
    init(
        navigationController: UINavigationController,
        dependencies: DependenciesContainer,
        vault: VaultDTO,
        operationToEdit: OperationDTO? = nil,
        operationType: OperationType? = nil,
        receipt: ReceiptOutput? = nil
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.vault = vault
        self.operationToEdit = operationToEdit
        self.operationType = operationType
        self.receipt = receipt
    }
    
    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = viewController
        navigationController.pushViewController(viewController, animated: true)
    }
    
    override func finish() {
        removeAllChildCoordinators()
        navigationController.popViewController(animated: true)
    }
    
    private lazy var viewModel: AddOperationViewModel = {
        
        let viewModel = self.dependencies.getAddOperationViewModel(
            with: vault,
            operationToEdit: operationToEdit,
            operationType: operationType,
            receipt: receipt
        )
        
        viewModel.delegate = self
        
        return viewModel
    }()
    
    lazy var viewController: AddOperationViewController = {
        
        let viewController = AddOperationViewController(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        
        return viewController
    }()
}

extension AddOperationCoordinator: AddOperationViewModelProtocol {
    
    func didAddOperation(_ viewModel: AddOperationViewModel) {
        finish()
    }
    
    func didEditOperation(_ viewModel: AddOperationViewModel) {
        finish()
    }
    
    func didTapAddReimbursement(_ viewModel: AddOperationViewModel) {
        navigateToAddReimbursement(with: viewModel.maximumReimbursementAvailable)
    }
}

extension AddOperationCoordinator: AddReimbursementViewModelDelegate {
    
    
    private func navigateToAddReimbursement(with maximumAmount: Double) {
        let viewModel = dependencies.getAddReimbursementViewModel(with: vault, and: maximumAmount)
        
        viewModel.delegate = self
        
        let viewController = AddReimbursementViewController(viewModel: viewModel)
        
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func didAddReimbursement(_ viewModel: AddReimbursementViewModel, reimbursement: ReimbursementDTO) {
        self.viewModel.addReimbursement(reimbursement)
        
        navigationController.popViewController(animated: true)
    }
    
    func didUpdateReimbursement(_ viewModel: AddReimbursementViewModel, reimbursement: ReimbursementDTO) {
        
        navigationController.popViewController(animated: true)
    }
}
