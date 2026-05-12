//
//  OperationsCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 30/03/2026.
//

import UIKit
import CoreKit
import VaultCore

class OperationsCoordinator: BaseCoordinator {

    // MARK: - Dependencies
    
    let navigationController: UINavigationController
    
    let dependencies: DependenciesContainer
    
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
        rootViewController = viewController
        self.navigationController.delegate = self
        self.navigationController.viewControllers = [ viewController ];
    }
    
    override func finish() {
        removeAllChildCoordinators()
    }
    
    // MARK: - ViewController's
    
    lazy var viewController: ListOperationsViewController = {
        
        let filter = OperationsFilter(
            startDate: Date().monthStart(),
            endDate: Date().monthEnd(),
            vault: vault
        )
        
        let viewModel = self.dependencies.getListOperationsViewModel(
            with: filter,
            canAddOperation: true,
            canFilter: true
        )
        
        viewModel.delegate = self
        
        let viewController = ListOperationsViewController(viewModel: viewModel)
        
        return viewController;
    }();
}

// MARK: - ListOperationsViewModel delegates
extension OperationsCoordinator: ListOperationsViewModelProtocol {
    
    func listOperationsDidTapAddOperation(of type: OperationType?, to vault: VaultDTO) {
        guard let type = type else {
            goToAddOperationWithVault(vault)
            return
        }
        
        goToAddOperationWithVault(vault, of: type)
    }
    
    func listOperationsDidTapEditOperation(_ operation: OperationDTO, in vault: VaultDTO) {
        self.goToAddOperationWithVault(vault, operationToEdit: operation)
    }

    func listOperationsDidSelectOperation(_ operation: OperationDTO) {
        goToOperationDetail(operation)
    }
    
    func listOperationsDidTapAddFromCamera(_ viewModel: ListOperationsViewModel) {
        goToOCR()
    }
    
    public func goToAddOperationWithVault(_ vault: VaultDTO, operationToEdit: OperationDTO? = nil) {
        
        let coordinator = OperationFormCoordinator(
            navigationController: navigationController,
            dependencies: self.dependencies,
            vault: vault,
            operationToEdit: operationToEdit
        )
        
        coordinator.start()
        
        addChildCoordinator(coordinator)
    }
    
    public func goToAddOperationWithVault(_ vault: VaultDTO, of type: OperationType) {
        
        let coordinator = OperationFormCoordinator(
            navigationController: navigationController,
            dependencies: self.dependencies,
            vault: vault,
            operationType: type
        )
        
        coordinator.start()
        
        addChildCoordinator(coordinator)
    }
    
    public func goToAddOperationWithReceipt(_ vault: VaultDTO, receipt: ReceiptOutput) {
        
        let coordinator = OperationFormCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            vault: vault,
            receipt: receipt
        )
        
        coordinator.start()
        
        addChildCoordinator(coordinator)
    }

    private func goToOperationDetail(_ operation: OperationDTO) {
        let viewModel = dependencies.getOperationDetailViewModel(with: operation)
        
        viewModel.delegate = self
        
        let viewController = OperationDetailViewController(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true

        navigationController.pushViewController(viewController, animated: true)
    }
}

extension OperationsCoordinator: OperationDetailViewModelDelegate {
    func viewModelDidDeleteOperation(_ viewModel: OperationDetailViewModel) {
        navigationController.popViewController(animated: true)
    }
    
    func viewModelDidTapEdit(_ viewModel: OperationDetailViewModel) {
        navigationController.popViewController(animated: true)
        
        goToAddOperationWithVault(
            vault,
            operationToEdit: viewModel.operation
        )
    }
    
    func viewModelDidTapEditReimbursement(_ viewModel: OperationDetailViewModel, reimbursement: ReimbursementDTO) {
        
        let viewModel = dependencies.getAddReimbursementViewModel(
            with: vault,
            and: 10000,
            reimbursementToEdit: reimbursement
        )
        
        viewModel.delegate = self
        
        let viewController = AddReimbursementViewController(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension OperationsCoordinator: AddReimbursementViewModelDelegate {
    func didAddReimbursement(_ viewModel: AddReimbursementViewModel, reimbursement: ReimbursementDTO) { }
    
    func didUpdateReimbursement(_ viewModel: AddReimbursementViewModel, reimbursement: ReimbursementDTO) {
        navigationController.popToRootViewController(animated: true)
    }
}

// MARK: - OCR
extension OperationsCoordinator: OCRCoordinatorDelegate {
    
    public func goToOCR() {
        let coordinator = OCRCoordinator(
            navigationController: navigationController,
            dependencies: dependencies
        )
        
        coordinator.delegate = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func coordinatorDidFinish(_ coordinator: OCRCoordinator) {
        
        removeChildCoordinator(coordinator)
    }
    
    func coordinatorDidFinish(_ coordinator: OCRCoordinator, with text: String) {
        
        viewController.startLoading()
        
        Task {
            do {
                
                let categoriesUseCase = self.dependencies.getListCategoryUseCase()
                
                let request = ListCategoriesRequest(vaultID: vault.id, operationType: .expense)
                
                let response = try categoriesUseCase.execute(request)
                
                let aiString = getCategoriesFormattedString(categories: response.categories)
                
                let receipt = try await ReceiptAssistant(categories: aiString)
                    .decodeReceipt(from: text) as ReceiptOutput
                
                await MainActor.run {
                    self.goToAddOperationWithReceipt(self.vault, receipt: receipt)
                    self.viewController.stopLoading()
                }
                
            } catch {
                print("OperationsCoordinator error: \(error.localizedDescription)")
            }
        }
        
        removeChildCoordinator(coordinator)
    }
}

private extension OperationsCoordinator {
    func getCategoriesFormattedString(categories: [CategoryDTO]) -> String {
        var string: String = ""
        for category in categories {
            string.append("\(category.aiBulletString)\n")
        }
        return string
    }
}

extension OperationsCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == rootViewController {
            cleanUpFinishedCoordinators()
        }
    }
    
    private func cleanUpFinishedCoordinators() {
        removeFinishedChildren(from: self)
    }
    
    private func removeFinishedChildren(from coordinator: BaseCoordinator) {
        
        coordinator.removeAllChildCoordinators()
    }
}
