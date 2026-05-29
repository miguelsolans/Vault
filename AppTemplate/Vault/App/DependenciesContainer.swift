//
//  DependenciesContainer.swift
//  Vault
//
//  Created by Miguel Solans on 05/04/2026.
//

import Foundation
import VaultCore

final class DependenciesContainer {
    
    static let shared = DependenciesContainer()
    
    private let core = CoreDependenciesContainer.shared
    
    // MARK: - Foundation Model
    
    private lazy var foundationModelManager: FoundationModelAvailability = {
        FoundationModelAvailability.shared
    }()
    
    private lazy var assistant: FinanceAssistant = {
        FinanceAssistant(
            dashboardUseCase: getDashboardUseCase()
        )
    }()

    private lazy var ocrTextRecognitionService: OCRTextRecognitionServiceProtocol = {
        VisionOCRTextRecognitionService()
    }()
    
    private init() {}
    
    func getUserDefaultsManager() -> UserDefaultsManager {
        core.getUserDefaultsManager()
    }
    
    func getKeychainManager() -> KeychainManager {
        core.getKeychainManager()
    }
}

// MARK: - Manager Accessors
extension DependenciesContainer {
    
    func getFinanceAssistant() -> FinanceAssistant {
        assistant
    }
}

// MARK: - ViewModel Factory Methods

extension DependenciesContainer {
    // MARK: Login Module
    func getLoginViewModel() -> LoginViewModel {
        return LoginViewModel(
            userDefaults: core.getUserDefaultsManager(),
            keychain: core.getKeychainManager()
        )
    }
    
    func getLoginPinViewModel() -> LoginPinViewModel {
        return LoginPinViewModel(
            keychain: core.getKeychainManager()
        )
    }
    
    // MARK: - Onboarding
    func getMarketingViewModel(configuration: MarketingConfiguration) -> MarketingViewModel {
        return MarketingViewModel(
            configuration: configuration
        )
    }
    
    // MARK: - Create Vault
    func getCreateVaultViewModel(vaultToEdit: VaultDTO? = nil) -> VaultFormViewModel {
        return VaultFormViewModel(
            createUseCase: getCreateVaultUseCase(),
            editUseCase: getEditVaultUseCase(),
            vaultToEdit: vaultToEdit
        )
    }
    
    // MARK: Dashboard Module
    func getDashboardViewModel(with vault: VaultDTO, filter: OperationsFilter) -> DashboardViewModel {
        return DashboardViewModel(
            dashboardUseCase: getDashboardUseCase(),
            vault: vault,
            filter: filter,
            foundationModelManager: foundationModelManager
        )
    }
    
    // MARK: - Breakdown Module
    func getCashflowBreakdownViewModel(filter: OperationsFilter) -> CashflowBreakdownViewModel {
        return CashflowBreakdownViewModel(
            filter: filter,
            useCase: getDashboardUseCase()
        )
    }
    
    // MARK: List Operations Module
    func getListOperationsViewModel(
        with filter: OperationsFilter,
        canAddOperation: Bool = true,
        canFilter: Bool = true
    ) -> ListOperationsViewModel {
        return ListOperationsViewModel(
            filter: filter,
            listUseCase: getListOperationsByDateUseCase(),
            deleteUseCase: getDeleteOperationUseCase(),
            foundationModelManager: foundationModelManager,
            canAddOperation: canAddOperation,
            canFilter: canFilter
        )
    }
    
    // MARK: Add Operation Module
    func getAddOperationViewModel(with vault: VaultDTO, operationToEdit: OperationDTO? = nil, operationType: OperationType? = nil, receipt: ReceiptOutput? = nil) -> OperationFormViewModel {
        
        return OperationFormViewModel(
            addOperationUseCase: getAddOperationUseCase(),
            editOperationUseCase: getEditOperationUseCase(),
            listCategoryUseCase: getListCategoryUseCase(),
            addReimbursementUseCase: getAddReimbursementUseCase(),
            updateReimbursementUseCase: getUpdateReimbursementStatusUseCase(),
            deleteReimbursementUseCase: getDeleteReimbursementUseCase(),
            vault: vault,
            operationToEdit: operationToEdit,
            operationType: operationType,
            receipt: receipt
        )
    }
    
    
    // MARK: List Categories Module
    func getListCategoriesViewModel(with vault: VaultDTO) -> ListCategoriesViewModel {
        return ListCategoriesViewModel(
            listUseCase: getListCategoryUseCase(),
            deleteUseCase: getDeleteCategoryUseCase(),
            vault: vault
        )
    }
    
    // MARK: - Category Detail Module
    func getCategoryDetailViewModel(with category: CategoryDTO) -> CategoryDetailViewModel {
        return CategoryDetailViewModel(
            deleteUseCase: getDeleteCategoryUseCase(),
            category: category
        )
    }
    
    // MARK: Add Category Module
    func getAddCategoryViewModel(with vault: VaultDTO, categoryToEdit: CategoryDTO? = nil) -> CategoryFormViewModel {
        return CategoryFormViewModel(
            addUseCase: getAddCategoryUseCase(),
            editUseCase: getEditCategoryUseCase(),
            vault: vault,
            categoryToEdit: categoryToEdit
        )
    }
    
    // MARK: - Settings
    func getSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(
            deleteDataUseCase: core.getDeleteAllDataUseCase()
        )
    }
    
    // MARK: - Security
    func getSecurityViewModel() -> SecurityViewModel {
        return SecurityViewModel(
            securityInfoUseCase: getSecurityInfoUseCase(),
            securityInfoUpdateUseCase: getSecurityInfoUpdateUseCase()
        )
    }
    
    // MARK: Create PIN Module
    func getCreatePinViewModel() -> CreatePinViewModel {
        return CreatePinViewModel(
            pinUseCase: getPinSetupUseCase()
        )
    }
    
    
    // MARK: TabBar Module
    func createTabBarViewModel() -> TabBarViewModel {
        TabBarViewModel()
    }
    
    // MARK: - Import operations
    func createImportOperationsViewModel(with vault: VaultDTO, andFileURL url: URL) -> ImportOperationsViewModel {
        return ImportOperationsViewModel(
            vault: vault,
            fileURL: url
        )
    }
    
    // MARK: - List vaults
    func createListVaultViewModel(canManageVaults: Bool) -> ListVaultViewModel {
        return ListVaultViewModel(
            listUseCase: getListVaultUseCase(),
            deleteUseCase: getDeleteVaultUseCase(),
            exportUseCase: getExportOperationsUseCase(),
            userDefaults: core.getUserDefaultsManager(),
            canManageVaults: canManageVaults
        )
    }
    
    // MARK: - Agent
    func createAgentViewModel() -> ChatViewModel {
        return ChatViewModel(
            assistant: assistant
        )
    }
    
    // MARK: - Sample
    func createSampleViewModel() -> SampleViewModel {
        return SampleViewModel()
    }

    // MARK: - OCR

    func getOCRViewModel() -> OCRViewModel {
        OCRViewModel(textRecognitionService: ocrTextRecognitionService)
    }
    
    func getOperationDetailViewModel(with operation: OperationDTO) -> OperationDetailViewModel {
        OperationDetailViewModel(
            operation: operation,
            operationDetailUseCase: getOperationDetailUseCase(),
            deleteOperationUseCase: getDeleteOperationUseCase(),
            updateReimbursementUseCase: getUpdateReimbursementStatusUseCase()
        )
    }
    
    // MARK: - Reimbursement
    
    func getAddReimbursementViewModel(with vault: VaultDTO, and maximumAmount: Double, reimbursementToEdit: ReimbursementDTO? = nil) -> ReimbursementFormViewModel {
        ReimbursementFormViewModel(
            vault: vault,
            maximumAmount: maximumAmount,
            listVaultUseCase: getListVaultUseCase(),
            listCategoryUseCase: getListCategoryUseCase(),
            updateReimbursementUseCase: getUpdateReimbursementUseCase(),
            reimbursementToEdit: reimbursementToEdit
        )
    }
}

// MARK: - Use Cases
extension DependenciesContainer {
    
    func getCurrencySeedUseCase() -> CurrencySeedUseCase {
        return core.getCurrencySeedUseCase()
    }
    
    func getVaultUseCase() -> GetVaultUseCase {
        return core.getVaultUseCase()
    }
    
    func getCreateVaultUseCase() -> CreateVaultUseCase {
        return core.getCreateVaultUseCase()
    }
    
    func getEditVaultUseCase() -> EditVaultUseCase {
        return core.getEditVaultUseCase()
    }
    
    func getListVaultUseCase() -> ListVaultUseCase {
        return core.getListVaultUseCase()
    }
    
    func getDeleteVaultUseCase() -> DeleteVaultUseCase {
        return core.getDeleteVaultUseCase()
    }
    
    func getListOperationsByDateUseCase() -> ListOperationsByDayUseCase {
        return core.getListOperationsByDateUseCase()
    }
    
    func getDeleteOperationUseCase() -> DeleteOperationUseCase {
        return core.getDeleteOperationUseCase()
    }
    
    func getOperationDetailUseCase() -> OperationDetailUseCase {
        return core.getOperationDetailUseCase()
    }
    
    func getListCategoryUseCase() -> ListCategoriesUseCase {
        return core.getListCategoryUseCase()
    }
    
    func getDeleteCategoryUseCase() -> DeleteCategoryUseCase {
        return core.getDeleteCategoryUseCase()
    }
    
    func getAddCategoryUseCase() -> AddCategoryUseCase {
        return core.getAddCategoryUseCase()
    }
    
    func getEditCategoryUseCase() -> EditCategoryUseCase {
        return core.getEditCategoryUseCase()
    }
    
    func getAddOperationUseCase() -> AddOperationsUseCase {
        return core.getAddOperationUseCase()
    }
    
    func getEditOperationUseCase() -> EditOperationUseCase {
        return core.getEditOperationUseCase()
    }
    
    func getDashboardUseCase() -> DashboardUseCase {
        return core.getDashboardUseCase()
    }
    
    func getExportOperationsUseCase() -> ExportOperationsUseCase {
        return core.getExportOperationsUseCase()
    }
    
    func getImportOperationsUseCase() -> ImportOperationsUseCase {
        return core.getImportOperationsUseCase()
    }
    
    func getAddReimbursementUseCase() -> AddReimbursementUseCase {
        return core.getAddReimbursementUseCase()
    }
    
    func getUpdateReimbursementStatusUseCase() -> UpdateReimbursementStatusUseCase {
        return core.getUpdateReimbursementStatusUseCase()
    }
    
    func getDeleteReimbursementUseCase() -> DeleteReimbursementUseCase {
        return core.getDeleteReimbursementUseCase()
    }
    
    func getUpdateReimbursementUseCase() -> UpdateReimbursementUseCase {
        return core.getUpdateReimbursementUseCase()
    }
    
    func getSecurityInfoUseCase() -> SecurityInfoUseCase {
        return core.getSecurityInfoUseCase()
    }
    
    func getSecurityInfoUpdateUseCase() -> SecurityInfoUpdateUseCase {
        return core.getSecurityInfoUpdateUseCase()
    }
    
    func getPinSetupUseCase() -> SecurityPinSetupUseCase {
        return core.getSecurityPinSetupUseCase()
    }
    
    func getCreateFeedbackUseCase() -> CreateFeedbackUseCase {
        return core.getCreateFeedbackUseCase()
    }
}
