//
//  AddCategoryViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 02/04/2026.
//

import Foundation
import AppUIKit
import UIKit
import VaultCore

protocol AddCategoryViewModelProtocol: AnyObject {
    func didAddCategory(_ viewModel: AddCategoryViewModel)
    func didUpdateCategory(_ viewModel: AddCategoryViewModel)
}

class AddCategoryViewModel: NSObject {
    private static let operationTypesInDisplayOrder: [OperationType] = [.expense, .income]

    weak var delegate: AddCategoryViewModelProtocol?
    
    // MARK: Dependencies
    
    private let addUseCase: AddCategoryUseCase
    
    private let editUseCase: EditCategoryUseCase

    private var vault: VaultDTO
    
    private var categoryToEdit: CategoryDTO?

    init(addUseCase: AddCategoryUseCase, editUseCase: EditCategoryUseCase, vault: VaultDTO, categoryToEdit: CategoryDTO? = nil) {
        self.addUseCase = addUseCase
        self.editUseCase = editUseCase
        self.vault = vault
        self.categoryToEdit = categoryToEdit
        super.init()
        setupBindings()
    }
    
    // MARK: - Input fields
    
    lazy var operationTypeInputViewModel: SegmentedInputViewModel = {
        let selectedValue = selectedIndex(for: categoryToEdit?.operationType ?? .expense)
        return SegmentedInputViewModel(
            title: NSLocalizedString("add_category_operation_type", tableName: "AddCategory", comment: ""),
            options: [
                NSLocalizedString("add_category_expense", tableName: "AddCategory", comment: ""),
                NSLocalizedString("add_category_income", tableName: "AddCategory", comment: "")
            ],
            selectedIndex: selectedValue,
            isEditable: categoryToEdit == nil,
            placeholder: nil,
            subtitle: nil,
            isMandatory: true
        )
    }()
    
    lazy var emojiInputViewModel: TextFieldInputViewModel = {
        TextFieldInputViewModel(
            title: "Emoji",
            isEditable: true,
            placeholder: "Emoji placeholder",
            subtitle: nil,
            inputText: categoryToEdit?.emoji ?? "",
            textType: .text,
            isMandatory: false
        )
    }()
    
    lazy var categoryNameInputViewModel: TextFieldInputViewModel = {
        TextFieldInputViewModel(
            title: NSLocalizedString("add_category_name", tableName: "AddCategory", comment: ""),
            isEditable: true,
            placeholder: NSLocalizedString("add_category_enter_category_name", tableName: "AddCategory", comment: ""),
            subtitle: nil,
            inputText: categoryToEdit?.title ?? "",
            textType: .text,
            isMandatory: true
        )
    }()

    lazy var colorInputViewModel: ColorPickerInputViewModel = {
        ColorPickerInputViewModel(
            title: NSLocalizedString("add_category_color", tableName: "AddCategory", comment: ""),
            selectedColor: UIColor(hexString: categoryToEdit?.color ?? String.randomHexColor()) ?? .green,
            isEditable: true,
            placeholder: "Color for plotting",
            subtitle: "Optional",
            isMandatory: false
        )
    }()
    
    lazy var plotSwitchInputViewModel: SwitchInputViewModel = {
        SwitchInputViewModel(
            title: NSLocalizedString("add_category_vault_plotting", tableName: "AddCategory", comment: ""),
            isOn: categoryToEdit?.visibleInPlot ?? false,
            isEditable: true,
            placeholder: NSLocalizedString("add_category_show_in_plot", tableName: "AddCategory", comment: ""),
            subtitle: NSLocalizedString("add_category_show_in_plot_subtitle", tableName: "AddCategory", comment: ""),
            isMandatory: false
        )
    }()
    
    lazy var budgetSwitchInputViewModel: SwitchInputViewModel = {
        SwitchInputViewModel(
            title: "Budget",
            isOn: categoryToEdit?.hasMonthlyBudget ?? false,
            isEditable: true,
            placeholder: "Set monthly budget",
            subtitle: "",
            isMandatory: false
        )
    }()
    
    lazy var budgetInputViewModel: TextFieldInputViewModel = {
        
        var amountText = "";
        
        if let categoryToEdit,
            let budget = categoryToEdit.monthlyBudget {
            
            amountText = LocalizedDecimalFormatter(numberStyle: .currency)
                .string(from: budget) ?? ""
        }
        
        return TextFieldInputViewModel(
            title: "Budget",
            isEditable: true,
            placeholder: "Monthly budget",
            subtitle: nil,
            inputText: amountText,
            textType: .currency("EUR"),
            isMandatory: true
        )
    }()
    
    // MARK: - State

    public var subtitle: String {
        if categoryToEdit != nil {
            return categoryToEdit?.title ?? ""
        }
        
        return vault.name
    }

    public var screenTitle: String {
        if categoryToEdit != nil {
            return NSLocalizedString("edit_category_title", tableName: "AddCategory", comment: "")
        }
        return NSLocalizedString("add_category_title", tableName: "AddCategory", comment: "")
    }
    
    public var isShowInDashboardOn: Bool {
        return plotSwitchInputViewModel.isOn
    }
    
    public var isBudgetOn: Bool {
        return budgetSwitchInputViewModel.isOn
    }
    
    public var isBudgetSectionVisible: Bool {
        return selectedOperationType() == .expense
    }
    
    var updateUI: (() -> Void)?
}

extension AddCategoryViewModel {
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

extension AddCategoryViewModel {
    func didTapSave() {
        
        guard validateInputs() else { return }

        let trimmedName = categoryNameInputViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let type = selectedOperationType() else {
            return
        }

        let colorHex = colorInputViewModel.selectedColor.toHexString()
        let visibleInPlot = plotSwitchInputViewModel.isOn
        let budget = LocalizedDecimalFormatter()
            .decimal(from: budgetInputViewModel.inputText)
        let emoji = emojiInputViewModel.inputText.isEmpty ? nil : emojiInputViewModel.inputText
        
        if let existingCategory = categoryToEdit {
            updateCategory(existingCategory, name: trimmedName, emoji: emoji, color: colorHex, type: type, visibleInPlot: visibleInPlot, budget: budget)
            return
        }
        
        saveCategory(
            name: trimmedName,
            emoji: emoji,
            color: colorHex,
            type: type,
            visibleInPlot: visibleInPlot,
            budget: budget
        )
    }
    
    func updateCategory(_ category: CategoryDTO, name: String, emoji: String? = nil, color: String?, type: OperationType, visibleInPlot: Bool, budget: NSDecimalNumber?) {
        do {
            let request = EditCategoryRequest(
                vaultID: vault.id,
                categoryID: category.id,
                newName: name,
                newEmoji: emoji,
                newColor: color,
                newType: type,
                newVisibleInPlot: visibleInPlot,
                newBudget: budget
            )
            
            let _ = try editUseCase.execute(request)
            
            delegate?.didUpdateCategory(self)
        } catch {
            // TODO: Present error?
        }
    }
    
    func saveCategory(name: String, emoji: String? = nil, color: String?, type: OperationType, visibleInPlot: Bool, budget: NSDecimalNumber?) {
        
        
        do {
            let request = AddCategoryRequest(
                vaultID: vault.id,
                name: name,
                emoji: emoji,
                color: color,
                type: type,
                visibleInPlot: visibleInPlot,
                budget: budget
            )
            
            let _ = try addUseCase.execute(request)
            
            delegate?.didAddCategory(self)
            
        } catch {
            
        }
    }
}

// MARK: - Form validations

extension AddCategoryViewModel {
    
    fileprivate func validateInputs() -> Bool {
        
        var valid = true
        
        if !validateName() {
            valid = false
        }
        
        return valid
    }
    
    private func validateName() -> Bool {
        
        let trimmedName = categoryNameInputViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            categoryNameInputViewModel.feedback = .error(NSLocalizedString("add_category_name_invalid", tableName: "AddCategory", comment: ""))
            return false
        }
        
        categoryNameInputViewModel.feedback = .none
        
        return true
    }
    
    /*private func categoryExists() -> Bool {
        
     .error(NSLocalizedString("add_category_name_already_exists_error", tableName: "AddCategory", comment: ""))
    }*/
}

extension AddCategoryViewModel {
    private func setupBindings() {
        setupOperationTypeBindings()
        setupEmojiBindings()
        setupCategoryBindings()
        setupPlottingBindings()
        setupBudgetBindings()
        setupAmountBindings()
    }
    
    private func setupOperationTypeBindings() {
        operationTypeInputViewModel.onSelectionChanged = { [weak self] _ in
            guard let self = self else { return }
            
            let isIncome = self.selectedOperationType() == .income
            
            if isIncome {
                self.budgetSwitchInputViewModel.isOn = false
            }
            
            updateUI?()
        }
    }
    
    private func setupEmojiBindings() {
        emojiInputViewModel.onBeginEditing = { [weak self] in
            guard let self = self else { return }
            
            self.emojiInputViewModel.feedback = .none
        }
    }
    
    private func setupCategoryBindings() {
        categoryNameInputViewModel.onBeginEditing = { [weak self] in
            guard let self = self else { return }
            
            self.categoryNameInputViewModel.feedback = .none
        }
    }
    
    private func setupPlottingBindings() {
        plotSwitchInputViewModel.onValueChanged = { [weak self] on in
            guard let self = self else { return }
            
            updateUI?()
        }
    }
    
    private func setupBudgetBindings() {
        budgetSwitchInputViewModel.onValueChanged = { [weak self] on in
            guard let self = self else { return }
            
            updateUI?()
        }
    }
    
    private func setupAmountBindings() {
        budgetInputViewModel.onBeginEditing = { [weak self] in
            guard let self = self else { return }
            
            self.budgetInputViewModel.feedback = .none
        }
    }
}

