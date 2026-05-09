//
//  AddOperationViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import Foundation
import AppUIKit
import VaultCore

protocol AddOperationViewModelProtocol: AnyObject {
    func didAddOperation(_ viewModel: AddOperationViewModel);
    func didEditOperation(_ viewModel: AddOperationViewModel);
    func didTapAddReimbursement(_ viewModel: AddOperationViewModel);
}

final class AddOperationViewModel: NSObject {
    
    private static let operationTypesInDisplayOrder: [OperationType] = [.expense, .income]
    
    weak var delegate: AddOperationViewModelProtocol?
    
    // MARK: - Dependencies
    
    private let addOperationUseCase: AddOperationsUseCase
    
    private let editOperationUseCase: EditOperationUseCase
    
    private let listCategoryUseCase: ListCategoriesUseCase
    
    private let listVaultUseCase: ListVaultUseCase
    
    private let addReimbursementUseCase: AddReimbursementUseCase
    
    private let updateReimbursementUseCase: UpdateReimbursementStatusUseCase
    
    private let deleteReimbursementUseCase: DeleteReimbursementUseCase
    
    private(set) var vault: VaultDTO
    
    private(set) var operationToEdit: OperationDTO?
    
    private(set) var operationType: OperationType?
    
    private(set) var receipt: ReceiptOutput?
    
    init(
        addOperationUseCase: AddOperationsUseCase,
        editOperationUseCase: EditOperationUseCase,
        listCategoryUseCase: ListCategoriesUseCase,
        listVaultUseCase: ListVaultUseCase,
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
        self.listVaultUseCase = listVaultUseCase
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
            return NSLocalizedString("edit_operation_title", tableName: "AddOperation", comment: "")
        }
        return NSLocalizedString("add_operation_title", tableName: "AddOperation", comment: "")
    }
    
    public var subtitle: String { vault.name }
    
    public lazy var ocrFeedback: FeedbackViewModel = {
        let viewModel = FeedbackViewModel(title: "Review data", subtitle: "You read a receipt from camera.\nImage to text recognition may provide inacurate data.", feedbackType: .informative)
        
        return viewModel
    }()
    
    public lazy var operationTypeInputViewModel: SegmentedInputViewModel = {
        
        var selectedValue = selectedIndex(for: operationToEdit?.operationType ?? .expense)
        
        if let operationType {
            selectedValue = selectedIndex(for: operationType)
        }
        
        let viewModel = SegmentedInputViewModel(
            title: NSLocalizedString("add_operation_operation_type", tableName: "AddOperation", comment: ""),
            options: [NSLocalizedString("add_operation_expense", tableName: "AddOperation", comment: ""), NSLocalizedString("add_operation_income", tableName: "AddOperation", comment: "")],
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
            title: NSLocalizedString("add_operation_category", tableName: "AddOperation", comment: ""),
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
            title: NSLocalizedString("add_operation_amount", tableName: "AddOperation", comment: ""),
            isEditable: isAmountEditable,
            placeholder: NSLocalizedString("add_operation_enter_amount", tableName: "AddOperation", comment: ""),
            subtitle: nil,
            inputText: amountText,
            textType: .currency(vault.currency.title),
            isMandatory: true
        )
    }()
    
    public lazy var titleInputViewModel: TextFieldInputViewModel = {
        
        var title = ""
        
        if let operationToEdit {
            title = operationToEdit.title
        }
        
        if let receipt {
            title = receipt.description ?? ""
        }
        
        let viewModel = TextFieldInputViewModel(
            title: NSLocalizedString("add_operation_description", tableName: "AddOperation", comment: ""),
            isEditable: true,
            placeholder: NSLocalizedString("add_operation_enter_description", tableName: "AddOperation", comment: ""),
            subtitle: nil,
            inputText: title,
            textType: .text,
            isMandatory: false
        )
        
        return viewModel;
    }()
    
    public lazy var dateInputViewModel: DatePickerInputViewModel = {
        let viewModel = DatePickerInputViewModel(
            title: NSLocalizedString("add_operation_date", tableName: "AddOperation", comment: ""),
            selectedDate: operationToEdit?.date ?? Date(),
            isEditable: true,
            placeholder: nil,
            subtitle: nil,
            isMandatory: true
        )
        
        viewModel.feedback = .info(NSLocalizedString("add_operation_vault_date_bottom_placeholder", tableName: "AddOperation", comment: ""))
        
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
            title: "Reimbursement",
            isOn: isOn,
            isEditable: isReimbursementEditable,
            placeholder: "Has a reimbursement",
            subtitle: "",
            isMandatory: false
        )
    }()
    
    // MARK: - State
    
    public var categories: [CategoryDTO] {
        didSet {
            updateCategoriesForSelectedOperationType()
        }
    }
    
    public var reimbursements: [ReimbursementDTO] = []
    
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
    
    public func reimbursementTableViewModel(at indexPath: IndexPath) -> TransferMoneyTableViewModel {
        let reimbursement = reimbursements[indexPath.row]

        return TransferMoneyTableViewModel(
            amount: LocalizedDecimalFormatter(numberStyle: .currency)
                .string(from: reimbursement.amount) ?? "\(reimbursement.amount)",
            sourceVaultName: reimbursement.sourceVault.name,
            destinationVaultName: reimbursement.destinationVault.name,
            status: reimbursement.status
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
}

// MARK: - Data

extension AddOperationViewModel {
    
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
            // TODO: Present error?
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
            // TODO: Present error?
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
            
            delegate?.didAddOperation(self)
            
        } catch {
            // TODO: Present error?
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
            delegate?.didEditOperation(self)
            
        } catch {
            // TODO: Present error?
        }
        
    }
    
    public func addReimbursement(_ reimbursement: ReimbursementDTO) {
        self.reimbursements.append(reimbursement)
        
        updateState()
    }
}

// MARK: - Actions

extension AddOperationViewModel {
    public func didTapSave() {
        
        guard validateInputs() else { return }
        
        if let operationToEdit {
            updateOperation(operationToEdit)
            return
        }
        
        createOperation()
    }
    
    func didTapAddReimbursement() {
        delegate?.didTapAddReimbursement(self)
    }
    
    func didTapDeleteReimbursement(at index: IndexPath) {
        
        let reimbursement = reimbursements[index.row]
        
        let request = DeleteReimbursementRequest(id: reimbursement.id)
        
        do {
            
            _ = try deleteReimbursementUseCase.execute(request)
            
            reimbursements.remove(at: index.row)
            
        } catch {
            
            reimbursements.remove(at: index.row)
            print("Got error: \(error.localizedDescription)")
            
        }
        
        updateState()
    }
    
    func didTapReceivedReimbursementStatus(at index: IndexPath) {
        updateReimbursementStatus(at: index, to: .received)
    }
    
    func didTapCancelledReimbursementStatus(at index: IndexPath) {
        updateReimbursementStatus(at: index, to: .cancelled)
    }
    
    func didTapExpectedReimbursementStatus(at index: IndexPath) {
        updateReimbursementStatus(at: index, to: .expected)
    }
}

// MARK: - Selection

extension AddOperationViewModel {
    
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


// MARK: - Validations

extension AddOperationViewModel {
    fileprivate func validateInputs() -> Bool {
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
            message: NSLocalizedString("add_operation_category_required", tableName: "AddOperation", comment: "")
        )
        
    }
    
    private func validateAmount() -> Bool {
        
        var valid: Bool = true
        
        valid = FormValidator.validateRequired(
            amountInputViewModel,
            message: NSLocalizedString("add_operation_amount_required", tableName: "AddOperation", comment: "")
        )
        
        if valid {
            valid = FormValidator.validatePositiveAmount(
                amountInputViewModel,
                message: NSLocalizedString("add_operation_invalid_amount", tableName: "AddOperation", comment: "")
            )
        }
        
        return valid
    }
    
    private func validateDescription() -> Bool {
        return FormValidator.validateRequired(
            titleInputViewModel,
            message: "Description can't be empty"
        )
    }
}

// MARK: - Bindings

extension AddOperationViewModel {
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
            
            // self.amountInputViewModel.isEditable = self.isAmountEditable
            
            self.reimbursements = []
            
            updateState()
        }
    }
}

extension AddOperationViewModel {
    private func updateState() {
        amountInputViewModel.isEditable = isAmountEditable
        reimbursementViewModel.isEditable = isReimbursementEditable
        
        updateUI?()
    }
}
