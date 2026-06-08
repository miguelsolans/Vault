//
//  OperationFormViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import Foundation
import CoreKit
import AppUIKit
import VaultCore

protocol OperationFormViewModelDelegate: AnyObject {
    func didAddOperation(_ viewModel: OperationFormViewModel)
    func didEditOperation(_ viewModel: OperationFormViewModel)
    func didTapAddReimbursement(_ viewModel: OperationFormViewModel)
}

final class OperationFormViewModel: NSObject {
    
    private static let operationTypesInDisplayOrder: [OperationType] = [.expense, .income]
    
    weak var delegate: OperationFormViewModelDelegate?
    
    // MARK: - Dependencies
    
    private let addOperationUseCase: AddOperationsUseCase
    
    private let editOperationUseCase: EditOperationUseCase
    
    private let listCategoryUseCase: ListCategoriesUseCase
    
    private let addReimbursementUseCase: AddReimbursementUseCase
    
    private let updateReimbursementUseCase: UpdateReimbursementStatusUseCase
    
    private let deleteReimbursementUseCase: DeleteReimbursementUseCase
    
    private var vault: VaultDTO
    
    private var operationToEdit: OperationDTO?
    
    private var operationType: OperationType?
    
    private var receipt: ReceiptOutput?
    
    init(
        addOperationUseCase: AddOperationsUseCase,
        editOperationUseCase: EditOperationUseCase,
        listCategoryUseCase: ListCategoriesUseCase,
        addReimbursementUseCase: AddReimbursementUseCase,
        updateReimbursementUseCase: UpdateReimbursementStatusUseCase,
        deleteReimbursementUseCase: DeleteReimbursementUseCase,
        vault: VaultDTO,
        operationToEdit: OperationDTO? = nil,
        operationType: OperationType? = nil,
        receipt: ReceiptOutput? = nil
    ) {
        self.addOperationUseCase = addOperationUseCase
        self.editOperationUseCase = editOperationUseCase
        self.listCategoryUseCase = listCategoryUseCase
        self.addReimbursementUseCase = addReimbursementUseCase
        self.updateReimbursementUseCase = updateReimbursementUseCase
        self.deleteReimbursementUseCase = deleteReimbursementUseCase
        self.vault = vault
        self.operationToEdit = operationToEdit
        self.operationType = operationType
        self.receipt = receipt
        self.categories = []
        self.reimbursements = operationToEdit?.reimbursements ?? []
        super.init()
        getData()
        setupBindings()
    }
    
    // MARK: - UI State
    
    public var title: String {
        if operationToEdit != nil {
            return L10n.EditOperation.pageTitle
        }
        return L10n.AddOperation.pageTitle
    }
    
    public var subtitle: String { vault.name }
    
    public lazy var ocrFeedback: FeedbackViewModel = {
        let viewModel = FeedbackViewModel(
            title: L10n.AddOperation.reviewDataTitle,
            subtitle: L10n.AddOperation.reviewDataMessage,
            feedbackType: .informative)
        
        return viewModel
    }()
    
    public lazy var operationTypeInputViewModel: SegmentedInputViewModel = {
        
        var selectedValue = selectedIndex(for: operationToEdit?.operationType ?? .expense)
        
        if let operationType {
            selectedValue = selectedIndex(for: operationType)
        }
        
        let viewModel = SegmentedInputViewModel(
            title: L10n.AddOperation.type,
            options: [
                L10n.Common.expense,
                L10n.Common.income
            ],
            selectedIndex: selectedValue,
            isEditable: isOperationTypeEditable,
            placeholder: nil,
            subtitle: nil,
            isMandatory: true
        )
        
        return viewModel;
    }()
    
    public lazy var categoryInputViewModel: OptionInputViewModel = {
        
        var selectedOption: String?;
        
        if let operationToEdit {
            selectedOption = operationToEdit.category.title
        }
        
        if let receipt {
            selectedOption = receipt.category
        }
        
        let viewModel = OptionInputViewModel(
            title: L10n.AddOperation.category,
            isEditable: true,
            placeholder: "",
            subtitle: "",
            options: [],
            selectedOption: selectedOption,
            isMandatory: true);
        
        return viewModel
    }()
    
    public lazy var amountInputViewModel: TextFieldInputViewModel = {

        var amountText: String = ""
        
        if let operationToEdit {
            amountText = LocalizedDecimalFormatter.init()
                .string(from: operationToEdit.amount) ?? ""
        }
        
        if let receipt,
            let amount = receipt.amount {
            amountText = LocalizedDecimalFormatter.init()
                .string(from: amount) ?? ""
        }

        return TextFieldInputViewModel(
            title: L10n.AddOperation.amount,
            isEditable: isAmountEditable,
            placeholder: L10n.AddOperation.enterAmount,
            subtitle: nil,
            inputText: amountText,
            textType: .currency(vault.currency.title),
            isMandatory: true
        )
    }()
    
    public lazy var titleInputViewModel: TextInputViewModel = {
        
        var title = ""
        
        if let operationToEdit {
            title = operationToEdit.title
        }
        
        if let receipt {
            title = receipt.description ?? ""
        }
        
        let viewModel = TextInputViewModel(
            title: L10n.AddOperation.description,
            isEditable: true,
            placeholder: L10n.AddOperation.enterDescription,
            subtitle: nil,
            inputText: title,
            isMandatory: false
        )
        
        return viewModel;
    }()
    
    public lazy var dateInputViewModel: DatePickerInputViewModel = {
        let viewModel = DatePickerInputViewModel(
            title: L10n.AddOperation.date,
            selectedDate: operationToEdit?.date ?? Date(),
            isEditable: true,
            placeholder: nil,
            subtitle: nil,
            isMandatory: true
        )
        
        return viewModel;
    }()
    
    public lazy var reimbursementViewModel: SwitchInputViewModel = {
        
        var isOn = false
        
        if let operationToEdit,
            let reimbursements = operationToEdit.reimbursements,
            let reimbursement = reimbursements.first {
            isOn = true
        }
        
        return SwitchInputViewModel(
            title: L10n.AddOperation.reimbursement,
            isOn: isOn,
            isEditable: isReimbursementEditable,
            placeholder: L10n.AddOperation.isSplitBill,
            subtitle: "",
            isMandatory: false
        )
    }()
    
    // MARK: - State
    
    private var categories: [CategoryDTO] {
        didSet {
            updateCategoriesForSelectedOperationType()
        }
    }
    
    private var reimbursements: [ReimbursementDTO] = []
    
    private var isOperationTypeEditable: Bool {
        get {
            
            if(receipt == nil && operationToEdit == nil && operationType == nil) {
                return true
            } else {
                return false
            }
            
        }
    }
    
    private var isAmountEditable: Bool {
        get {
            
            if reimbursements.count > 0 {
                return false
            }
            
            return true
            
        }
    }
    
    private var isReimbursementEditable: Bool {
        get {
            
            if operationToEdit != nil {
                return false
            }
            
            if amountInputViewModel.inputText.isEmpty {
                return false
            }
            
            if reimbursements.count > 0 {
                return false
            }
            
            return true
        }
    }
    
    public var isOcrFeedbackHidden: Bool {
        get {
            return receipt == nil
        }
    }
    
    public var isReimbursementHidden: Bool {
        get {
            selectedOperationType() == .income
        }
    }
    
    public var isReimbursmentSwitchHidden: Bool {
        get {
            operationToEdit != nil
        }
    }
    
    public var isAddReimbursementHidden: Bool {
        get {
            
            if operationToEdit != nil || !isReimbursementOn {
                return true
            }
            
            if maximumReimbursementAvailable <= 0 {
                return true
            }
            
            return false
        }
    }
    
    public var maximumReimbursementAvailable: Double {
        let operationAmount = LocalizedDecimalFormatter()
            .double(from: amountInputViewModel.inputText) ?? 0
        
        let reimbursement = reimbursements.reduce(0) { $0 + $1.amount }
        
        return operationAmount - reimbursement
    }
    
    public var isReimbursementOn: Bool {
        get {
            reimbursementViewModel.isOn
        }
    }
    
    public var numberOfReimbursements: Int {
        reimbursements.count
    }
    
    public func reimbursementTableViewModel(at indexPath: IndexPath) -> ReimbursementTableViewModel {
        let reimbursement = reimbursements[indexPath.row]

        return ReimbursementTableViewModel(
            status: reimbursement.status,
            title: reimbursement.notes,
            amount: reimbursement.amount
        )
    }
    
    public func isLeadingAvailable(_ status: ReimbursementStatus, for indexPath: IndexPath) -> Bool {
        
        if operationToEdit == nil {
            return false
        }
        
        let reimbursement = reimbursements[indexPath.row]
        
        return reimbursement.status != status
    }
    
    public func isDeleteReimbursementAvailable(for indexPath: IndexPath) -> Bool {
        return operationToEdit == nil
    }
    
    // MARK: - Bindings
    
    public var updateUI: (() -> Void)?
    
    public var onSuccess: ((ViewModelFeedback) -> Void)?
    
    public var onError: ((ViewModelFeedback) -> Void)?
}

// MARK: - Data

extension OperationFormViewModel {
    
    public func getData() {
        getCategories()
    }
    
    private func getCategories() {
        
        categoryInputViewModel.options = []
        
        do {
            let request = ListCategoriesRequest(
                vaultID: vault.id,
                operationType: selectedOperationType()
            )
            
            let response = try listCategoryUseCase.execute(request)
            
            self.categories = response.categories
            
        } catch {
            onError?(.showAlert(message: L10n.AddOperation.errorFetchingCategories))
        }
    }
    
    private func updateCategoriesForSelectedOperationType() {
        
        if categories.isEmpty {
            categoryInputViewModel.options = []
            categoryInputViewModel.selectedOption = nil
            categoryInputViewModel.isEditable = false
            
            return
        }
        
        var labels = [String]()
        
        for category in self.categories {
            labels.append(category.title)
        }
        
        categoryInputViewModel.options = labels
        
        categoryInputViewModel.isEditable = true
        
        if let operationToEdit, labels.contains(operationToEdit.category.title) {
            
            categoryInputViewModel.selectedOption = operationToEdit.category.title
            
        } else if let receipt {
          
            categoryInputViewModel.selectedOption = receipt.category
            
        } else {
            categoryInputViewModel.selectedOption = nil
        }
        
        updateUI?()
    }
    
    private func updateReimbursementStatus(at index: IndexPath, to status: ReimbursementStatus) {
        guard reimbursements.indices.contains(index.row) else {
            return
        }
        
        let reimbursement = reimbursements[index.row]
        
        let request = UpdateReimbursementStatusRequest(
            id: reimbursement.id,
            status: status
        )
        
        do {
            let response = try updateReimbursementUseCase.execute(request)
            reimbursements[index.row] = response.reimbursement
            updateUI?()
        } catch {
            onError?(.showAlert(message: L10n.AddOperation.errorUpdatingReimbursementStatus))
        }
    }
    
    private func createOperation() {
        guard let type = selectedOperationType() else {
            return
        }
        
        guard let amount = LocalizedDecimalFormatter()
            .double(from: amountInputViewModel.inputText) else {
            return
        }
        
        guard let selectedCategoryName = self.categoryInputViewModel.selectedOption,
              let selectedCategory = self.categories.first(where: {
                  $0.title == selectedCategoryName && $0.operationType == type
              }) else {
            return
        }
        
        let request = AddOperationsRequest(
            vaultID: vault.id,
            categoryID: selectedCategory.id,
            amount: amount,
            type: type,
            title: titleInputViewModel.inputText,
            notes: "",
            date: dateInputViewModel.selectedDate
        )
        
        do {
            
            let result = try addOperationUseCase.execute(request)
            
            if reimbursementViewModel.isOn {
                try createReimbursement(operation: result.operation)
            }
            
            onSuccess?(.silent)
            
            delegate?.didAddOperation(self)
            
        } catch {
            onError?(.showAlert(message: L10n.AddOperation.errorCreatingOperation))
        }
    }
    
    private func createReimbursement(operation: OperationDTO) throws {
        
        guard reimbursementViewModel.isOn else {
            return
        }
        
        let requests = reimbursements.compactMap { reimbursement -> AddReimbursementRequest in
            return AddReimbursementRequest(
                amount: reimbursement.amount,
                notes: reimbursement.notes,
                status: reimbursement.status,
                sourceVaultID: reimbursement.sourceVault.id,
                destinationVaultID: reimbursement.destinationVault.id,
                categoryID: reimbursement.destinationCategory!.id,
                sourceOperationID: operation.id
            )
        }
        
        for request in requests {
            _ = try addReimbursementUseCase.execute(request)
        }
    }
    
    private func updateOperation(_ operation: OperationDTO) {
        
        guard let type = selectedOperationType() else {
            return
        }
        
        guard let amount = LocalizedDecimalFormatter()
            .double(from: amountInputViewModel.inputText) else {
            return
        }
        
        guard let selectedCategoryName = self.categoryInputViewModel.selectedOption,
              let selectedCategory = self.categories.first(where: {
                  $0.title == selectedCategoryName
              }) else {
            return
        }
        
        let request = EditOperationRequest(
            operationID: operation.id,
            categoryID: selectedCategory.id,
            title: self.titleInputViewModel.inputText,
            date: self.dateInputViewModel.selectedDate,
            type: type,
            amount: amount,
            notes: ""
        )
        
        do {
            
            let _ = try editOperationUseCase.execute(request)
            
            onSuccess?(.silent)
            
            delegate?.didEditOperation(self)
            
        } catch {
            onError?(.showAlert(message: L10n.EditOperation.errorUpdatingOperation))
        }
        
    }
    
    public func addReimbursement(_ reimbursement: ReimbursementDTO) {
        self.reimbursements.append(reimbursement)
        
        updateState()
    }
}

// MARK: - Actions -

extension OperationFormViewModel {
    public func didTapSave() {
        
        guard validateInputs() else { return }
        
        if let operationToEdit {
            updateOperation(operationToEdit)
            return
        }
        
        createOperation()
    }
    
    public func didTapAddReimbursement() {
        delegate?.didTapAddReimbursement(self)
    }
    
    public func didTapDeleteReimbursement(at index: IndexPath) {
        let reimbursement = reimbursements[index.row]
        
        if operationToEdit == nil {
            reimbursements.remove(at: index.row)
            
            updateState()
            
            return
        }
        
        let request = DeleteReimbursementRequest(id: reimbursement.id)
        
        do {
            
            _ = try deleteReimbursementUseCase.execute(request)
            
            reimbursements.remove(at: index.row)
            
        } catch {
            onError?(.showAlert(message: L10n.EditOperation.errorDeletingReimbursement))
        }
        
        updateState()
    }
    
    public func didTapReceivedReimbursementStatus(at index: IndexPath) {
        updateReimbursementStatus(at: index, to: .received)
    }
    
    public func didTapCancelledReimbursementStatus(at index: IndexPath) {
        updateReimbursementStatus(at: index, to: .cancelled)
    }
    
    public func didTapExpectedReimbursementStatus(at index: IndexPath) {
        updateReimbursementStatus(at: index, to: .expected)
    }
}

// MARK: - Validations

extension OperationFormViewModel {
    private func validateInputs() -> Bool {
        var isValid = true
        
        if !validateCategory() {
            isValid = false
        }
        
        if !validateAmount() {
            isValid = false
        }
        
        if !validateDescription() {
            isValid = false
        }
        
        return isValid
    }
    
    private func validateCategory() -> Bool {
        
        return FormValidator.validateRequired(
            categoryInputViewModel,
            message: L10n.AddOperation.categoryRequired
        )
        
    }
    
    private func validateAmount() -> Bool {
        
        var valid: Bool = true
        
        valid = FormValidator.validateRequired(
            amountInputViewModel,
            message: L10n.AddOperation.amountRequired
        )
        
        if valid {
            valid = FormValidator.validatePositiveAmount(
                amountInputViewModel,
                message: L10n.AddOperation.amountInvalid
            )
        }
        
        return valid
    }
    
    private func validateDescription() -> Bool {
        return FormValidator.validateRequired(
            titleInputViewModel,
            message: L10n.AddOperation.descriptionRequired
        )
    }
}

// MARK: - Bindings

extension OperationFormViewModel {
    private func setupBindings() {
        setupOperationTypeBindings()
        setupCategoryBindings()
        setupAmountBindings()
        setupDescriptionBindings()
        setupReimbursementSwitchBindings()
    }
    
    private func setupOperationTypeBindings() {
        operationTypeInputViewModel.onSelectionChanged = { [weak self] _ in
            guard let self = self else { return }
            
            self.getCategories()
            
            self.reimbursementViewModel.isOn = false
        }
    }
    
    private func setupAmountBindings() {
        amountInputViewModel.onBeginEditing = { [weak self] in
            guard let self = self else { return }
            
            self.amountInputViewModel.feedback = .none
        }
        
        amountInputViewModel.onEndEditing = { [weak self] in
            guard let self = self else { return }
            
            self.reimbursementViewModel.isEditable = self.isReimbursementEditable
        }
    }
    
    private func setupCategoryBindings() {
        categoryInputViewModel.onBeginChoosing = { [weak self] in
            guard let self = self else { return }
            
            self.categoryInputViewModel.feedback = .none
        }
        
    }
    
    private func setupDescriptionBindings() {
        titleInputViewModel.onBeginEditing = { [weak self] in
            guard let self = self else { return }
            
            titleInputViewModel.feedback = .none
        }
    }
    
    private func setupReimbursementSwitchBindings() {
        reimbursementViewModel.onValueChanged = { [weak self] isOn in
            guard let self = self else { return }
            
            self.reimbursements = []
            
            updateState()
        }
    }
}

// MARK: - Helper -

extension OperationFormViewModel {
    
    private func updateState() {
        amountInputViewModel.isEditable = isAmountEditable
        reimbursementViewModel.isEditable = isReimbursementEditable
        
        if isAmountEditable {
            amountInputViewModel.feedback = .none
        } else {
            amountInputViewModel.feedback = .info(L10n.AddOperation.removeReimbursementToEditAmount)
        }
        
        updateUI?()
    }
    
    private func selectedIndex(for operationType: OperationType) -> Int {
        Self.operationTypesInDisplayOrder.firstIndex(of: operationType) ?? 0
    }
    
    private func selectedOperationType() -> OperationType? {
        guard let selectedIndex = operationTypeInputViewModel.selectedIndex,
              Self.operationTypesInDisplayOrder.indices.contains(selectedIndex) else {
            return nil
        }
        
        return Self.operationTypesInDisplayOrder[selectedIndex]
    }
}
