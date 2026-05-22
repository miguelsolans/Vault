//
//  ReimbursementFormViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 30/04/2026.
//

import UIKit
import CoreKit
import AppUIKit
import VaultCore

protocol ReimbursementFormViewModelDelegate: AnyObject {
    func didAddReimbursement(_ viewModel: ReimbursementFormViewModel, reimbursement: ReimbursementDTO)
    func didUpdateReimbursement(_ viewModel: ReimbursementFormViewModel, reimbursement: ReimbursementDTO)
}

final class ReimbursementFormViewModel: NSObject {
    
    weak var delegate: ReimbursementFormViewModelDelegate?
    
    // MARK: - Dependencies
    
    private var vault: VaultDTO
    
    private var reimbursementToEdit: ReimbursementDTO?
    
    private(set) var maximumAmount: Double
    
    private let listVaultUseCase: ListVaultUseCase
    
    private let listCategoryUseCase: ListCategoriesUseCase
    
    private let updateReimbursementUseCase: UpdateReimbursementUseCase
    
    init(
        vault: VaultDTO,
        maximumAmount: Double,
        listVaultUseCase: ListVaultUseCase,
        listCategoryUseCase: ListCategoriesUseCase,
        updateReimbursementUseCase: UpdateReimbursementUseCase,
        reimbursementToEdit: ReimbursementDTO? = nil
    ) {
        self.vault = vault
        self.maximumAmount = maximumAmount
        self.listVaultUseCase = listVaultUseCase
        self.listCategoryUseCase = listCategoryUseCase
        self.updateReimbursementUseCase = updateReimbursementUseCase
        self.reimbursementToEdit = reimbursementToEdit
        super.init()
        setupBindings()
        getData()
    }
    
    // MARK: - UI State
    
    public var title: String {
        
        if reimbursementToEdit != nil {
            return "Edit Reimbursement"
        }
        
        return "Add Reimbursement"
    }
    
    public var subtitle: String { "" }
    
    public lazy var amountFeedbackViewModel: FeedbackViewModel = {
        
        let formattedAmount = currencyFormatter.string(from: maximumAmount) ?? "\(maximumAmount)"
        let bodyText = "You can add a reimbursement up to \(formattedAmount)"
        let attributedBody = bodyText.styled(
            baseAttributes: [
                .font: FeedbackStyles.informativeFeedback.subtitleFont,
                .foregroundColor: FeedbackStyles.informativeFeedback.subtitleColor
            ],
            highlights: [
                TextHighlight(text: formattedAmount, attributes: [
                    .font: AppFonts.feedbackBodyBold
                ])
            ]
        )
        
        return FeedbackViewModel(
            title: "Maximum reimbursement allowed",
            subtitleAttributed: attributedBody,
            feedbackType: .informative
        )
    }()
    
    public lazy var statusInputViewModel: SegmentedInputViewModel = {
        
        let viewModel = SegmentedInputViewModel(
            title: "Status",
            options: ["Expected", "Received", "Cancelled"],
            selectedIndex: 0,
            isEditable: isStatusEditable,
            placeholder: nil,
            subtitle: nil,
            isMandatory: true
        )
        
        return viewModel;
    }()
    
    
    public lazy var amountInputViewModel: TextFieldInputViewModel = {
        
        var amountText: String = ""
        
        if let reimbursementToEdit {
            amountText = LocalizedDecimalFormatter()
                .string(from: reimbursementToEdit.amount) ?? ""
        }
        
        return TextFieldInputViewModel(
            title: "Reimbursing amount",
            isEditable: isAmountEditable,
            placeholder: "Enter amount",
            subtitle: nil,
            inputText: amountText,
            textType: .currency(vault.currency.title),
            isMandatory: true
        )
    }()
    
    public lazy var notesInputViewModel: TextFieldInputViewModel = {
        
        return TextFieldInputViewModel(
            title: "Notes",
            isEditable: true,
            placeholder: "Enter notes",
            subtitle: nil,
            inputText: reimbursementToEdit?.notes ?? "",
            textType: .text,
            isMandatory: true
        )
    }()
    
    public lazy var depositVaultViewModel: OptionInputViewModel = {
        
        var selectedOption: String?
        
        if let reimbursementToEdit {
            selectedOption = reimbursementToEdit.destinationVault.name
        }
        
        return OptionInputViewModel(
            title: "Deposit Vault",
            isEditable: isDepositVaultEditable,
            placeholder: "Choose deposit Vault",
            subtitle: "",
            options: [],
            selectedOption: selectedOption,
            isMandatory: true
        );
    }()
    
    public lazy var depositFeedbackViewModel: FeedbackViewModel = {
        return FeedbackViewModel(
            title: "Deposit Vault different from source Vault",
            subtitle: "You selected a different Vault for the deposit. You will receive an income operation in the selected deposit Vault.",
            feedbackType: .informative
        )
    }()
    
    public var depositFeedbackHidden: Bool {
        guard let depositVault else {
            return true
        }
        
        return depositVault.id == vault.id
    }
    
    public lazy var depositCategoryViewModel: OptionInputViewModel = {
        
        var selectedOption: String?
        
        if let reimbursementToEdit {
            selectedOption = reimbursementToEdit.destinationCategory?.title
        }
        
        return OptionInputViewModel(
            title: "Deposit income category",
            isEditable: isDepositCategoryEditable,
            placeholder: "Choose deposit category",
            subtitle: "",
            options: [],
            selectedOption: selectedOption,
            isMandatory: true
        );
    }()
    
    private var depositVault: VaultDTO? {
        get {
            self.vaults.first(where: {
                $0.name == self.depositVaultViewModel.selectedOption
            })
        }
    }
    
    private var depositCategory: CategoryDTO? {
        get {
            self.categories.first(where: {
                $0.title == self.depositCategoryViewModel.selectedOption
            })
        }
    }
    
    private var isStatusEditable: Bool {
        get {
            return reimbursementToEdit == nil
        }
    }
    
    private var isAmountEditable: Bool {
        get {
            return reimbursementToEdit == nil
        }
    }
    
    private var isDepositVaultEditable: Bool {
        get {
            return reimbursementToEdit == nil
        }
    }
    
    private var isDepositCategoryEditable: Bool {
        get {
            return reimbursementToEdit == nil
        }
    }
    
    private var currencyFormatter: LocalizedDecimalFormatter {
        LocalizedDecimalFormatter(numberStyle: .currency)
    }
    
    // MARK: - State
    
    private var vaults: [VaultDTO] = []
    
    private var categories: [CategoryDTO] = []
    
    // MARK: - Bindings
    
    public var updateUI: (() -> Void)?
    
    public var onSuccess: ((ViewModelFeedback) -> Void)?
    
    public var onError: ((ViewModelFeedback) -> Void)?
}

// MARK: - Data

extension ReimbursementFormViewModel {
    public func getData() {
        getVaults()
    }
    
    private func getVaults() {
        
        depositVaultViewModel.options = []
        
        do {
            
            let request = ListVaultRequest()
            
            let response = try listVaultUseCase.execute(request)
            
            self.vaults = response.vaults
            
            var vaultLabels: [String] = []
            
            for vault in response.vaults {
                vaultLabels.append(vault.name)
            }
            
            depositVaultViewModel.options = vaultLabels
            
            depositVaultViewModel.isEditable = true
            
            if let reimbursementToEdit {
                depositVaultViewModel.selectedOption = reimbursementToEdit.destinationVault.name
            }
            
        } catch {
            onError?(.showAlert(message: "There was an error while fetching your Vaults. Please try again."))
        }
    }
    
    private func getCategories() {
        
        depositCategoryViewModel.options = []
        
        guard let depositVault = depositVault else {
            return
        }
        
        do {
            
            let request = ListCategoriesRequest(
                vaultID: depositVault.id,
                operationType: .income
            )
            
            let response = try listCategoryUseCase.execute(request)
            
            var categoryLabels: [String] = []
            
            for category in response.categories {
                categoryLabels.append(category.title)
            }
            
            depositCategoryViewModel.options = categoryLabels
            
            depositCategoryViewModel.isEditable = true
            
            self.categories = response.categories

            if let reimbursementToEdit {
                depositCategoryViewModel.selectedOption = reimbursementToEdit.destinationCategory?.title
            }
            
        } catch {
            onError?(.showAlert(message: "There was an error while fetching categories from Vault \(depositVault.name). Please try again."))
        }
    }
}


// MARK: - Actions

extension ReimbursementFormViewModel {
    public func saveTapped() {
        
        guard validate() else {
            onError?(.silent)
            return
        }
        
        guard reimbursementToEdit != nil else {
            createReimbursement()
            return
        }
        
        saveReimbursement()
    }
}

// MARK: - Validations

extension ReimbursementFormViewModel {
    
    private func validateAmount() -> Bool {
        
        var valid = FormValidator.validateRequired(
            amountInputViewModel,
            message: "Enter a valid amount")
        
        if valid {
            valid = FormValidator.validatePositiveAmount(
                amountInputViewModel,
                message: "Amount should be greater than zero"
            )
        }
        
        if valid {
            valid = FormValidator.validateAmount(
                amountInputViewModel,
                condition: .lessThanOrEqual(maximumAmount),
                message: "Amount should be less or equal the maximum amount"
            )
        }
        
        return valid
    }
    
    private func validateDepositVault() -> Bool {
        return FormValidator.validateRequired(
            depositVaultViewModel,
            message: "Deposit vault is required"
        )
    }
    
    private func validateDepositCategory() -> Bool {
        return FormValidator.validateRequired(
            depositCategoryViewModel,
            message: "Deposit category is required"
        )
    }
    
    private func validate() -> Bool {
        var valid = true
        
        if !self.validateAmount() {
            valid = false
        }
        
        if !self.validateDepositVault() {
            valid = false
        }
        
        if !self.validateDepositCategory() {
            valid = false
        }
        
        return valid
    }
    
    private func createReimbursement() {
        guard let depositVault = depositVault,
              let depositCategory = depositCategory,
              let status = selectedStatus() else {
            return
        }
        
        let amount = LocalizedDecimalFormatter()
            .double(from: amountInputViewModel.inputText) ?? 0.0
        
        
        let reimbursement = ReimbursementDTO(
            id: UUID(),
            amount: amount,
            notes: notesInputViewModel.inputText,
            status: status,
            sourceVault: vault,
            destinationVault: depositVault,
            destinationCategory: depositCategory
        )
        
        onSuccess?(.silent)
        
        delegate?.didAddReimbursement(self, reimbursement: reimbursement)
    }
    
    private func saveReimbursement() {
        guard let reimbursementToEdit,
                let category = depositCategory
        else { return }
        
        let request = UpdateReimbursementRequest(
            id: reimbursementToEdit.id,
            notes: notesInputViewModel.inputText,
            categoryID: category.id
        )
        
        do {
            _ = try updateReimbursementUseCase.execute(request)
            
            onSuccess?(.silent)
            
            delegate?.didUpdateReimbursement(self, reimbursement: reimbursementToEdit)
        } catch {
            onError?(.showAlert(message: "An error ocurred saving the Reimbursement"))
        }
    }
}

// MARK: - Bindings

extension ReimbursementFormViewModel {
    private func setupBindings() {
        setupAmountBindings()
        setupDepositVaultBindings()
        setupDepositCategoryBindings()
    }
    
    private func setupAmountBindings() {
        amountInputViewModel.onTextChanged = { [weak self] _ in
            guard let self = self else { return }
            
            self.amountInputViewModel.feedback = .none
        }
    }
    
    private func setupDepositVaultBindings() {
        depositVaultViewModel.onBeginChoosing = { [weak self] in
            guard let self = self else { return }
            
            self.depositVaultViewModel.feedback = .none
        }
        
        depositVaultViewModel.onSelectionChanged = { [weak self] option in
            guard let self = self else { return }
            self.depositVaultViewModel.feedback = .none
            self.getCategories()
            self.updateUI?()
        }
        
        depositVaultViewModel.onEndChoosing = { [weak self] in
            guard let self = self else { return }
            self.depositVaultViewModel.feedback = .none
            self.updateUI?()
        }
    }
    
    private func setupDepositCategoryBindings() {
        depositCategoryViewModel.onBeginChoosing = { [weak self] in
            guard let self = self else { return }
            self.depositCategoryViewModel.feedback = .none
        }
        
        depositCategoryViewModel.onSelectionChanged = { [weak self] option in
            guard let self = self else { return }
            self.depositCategoryViewModel.feedback = .none
            
        }
        
        depositCategoryViewModel.onEndChoosing = { [weak self] in
            guard let self = self else { return }
            self.depositCategoryViewModel.feedback = .none
        }
    }
}

// MARK. - Helper
extension ReimbursementFormViewModel {
    private func updateCategories() {
        var labels = [String]()
        
        for category in categories {
            labels.append(category.title)
        }
        
        depositCategoryViewModel.options = labels
    }
    
    private func selectedStatus() -> ReimbursementStatus? {
        guard let selectedIndex = statusInputViewModel.selectedIndex else {
            return nil
        }
        
        return ReimbursementStatus(rawValue: Int16(selectedIndex))
    }
}
