//
//  CategoryFormViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 02/04/2026.
//

import Foundation
import AppUIKit
import UIKit
import VaultCore

protocol CategoryFormViewModelDelegate: AnyObject {
    func didAddCategory(_ viewModel: CategoryFormViewModel)
    func didUpdateCategory(_ viewModel: CategoryFormViewModel)
}

final class CategoryFormViewModel: NSObject {
    private static let operationTypesInDisplayOrder: [OperationType] = [.expense, .income]

    weak var delegate: CategoryFormViewModelDelegate?
    
    // MARK: Dependencies
    
    private let addUseCase: AddCategoryUseCase
    
    private let editUseCase: EditCategoryUseCase

    private var vault: VaultDTO
    
    private var categoryToEdit: CategoryDTO?

    init(
        addUseCase: AddCategoryUseCase,
        editUseCase: EditCategoryUseCase,
        vault: VaultDTO,
        categoryToEdit: CategoryDTO? = nil
    ) {
        self.addUseCase = addUseCase
        self.editUseCase = editUseCase
        self.vault = vault
        self.categoryToEdit = categoryToEdit
        super.init()
        setupBindings()
    }
    
    // MARK: - UI State
    
    public var title: String {
        if categoryToEdit != nil {
            return NSLocalizedString("edit_category_title", tableName: "AddCategory", comment: "")
        }
        return NSLocalizedString("add_category_title", tableName: "AddCategory", comment: "")
    }
    
    public var subtitle: String {
        if categoryToEdit != nil {
            return categoryToEdit?.title ?? ""
        }
        
        return vault.name
    }
    
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
            isMandatory: false,
            maxCharacters: 1
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
    
    public var isShowInDashboardOn: Bool {
        return plotSwitchInputViewModel.isOn
    }
    
    public var isBudgetSectionVisible: Bool {
        return selectedOperationType() == .expense
    }
    
    // MARK: - Bindings

    public var updateUI: (() -> Void)?
    
    public var onError: (() -> Void)?
}

// MARK: - Actions -
extension CategoryFormViewModel {
    func didTapSave() {
        
        guard validateInputs() else { return }

        let trimmedName = categoryNameInputViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let type = selectedOperationType() else {
            return
        }

        let colorHex = colorInputViewModel.selectedColor.toHexString()
        let visibleInPlot = plotSwitchInputViewModel.isOn
        let emoji = emojiInputViewModel.inputText.isEmpty ? nil : emojiInputViewModel.inputText
        
        if let existingCategory = categoryToEdit {
            updateCategory(existingCategory, name: trimmedName, emoji: emoji, color: colorHex, type: type, visibleInPlot: visibleInPlot)
            return
        }
        
        saveCategory(
            name: trimmedName,
            emoji: emoji,
            color: colorHex,
            type: type,
            visibleInPlot: visibleInPlot
        )
    }
    
    private func updateCategory(_ category: CategoryDTO, name: String, emoji: String? = nil, color: String?, type: OperationType, visibleInPlot: Bool) {
        do {
            let request = EditCategoryRequest(
                vaultID: vault.id,
                categoryID: category.id,
                newName: name,
                newEmoji: emoji,
                newColor: color,
                newType: type,
                newVisibleInPlot: visibleInPlot
            )
            
            let _ = try editUseCase.execute(request)
            
            delegate?.didUpdateCategory(self)
        } catch CategoryError.categoryAlreadyExists {
            categoryNameInputViewModel.feedback = .error("Category with name \(name) already exists")
            onError?()
        } catch {
            
        }
    }
    
    private func saveCategory(name: String, emoji: String? = nil, color: String?, type: OperationType, visibleInPlot: Bool) {
        
        do {
            let request = AddCategoryRequest(
                vaultID: vault.id,
                name: name,
                emoji: emoji,
                color: color,
                type: type,
                visibleInPlot: visibleInPlot
            )
            
            let _ = try addUseCase.execute(request)
            
            delegate?.didAddCategory(self)
            
        } catch CategoryError.categoryAlreadyExists {
            categoryNameInputViewModel.feedback = .error("Category with name \(name) already exists")
            onError?()
        } catch {
            
        }

    }
}

// MARK: - Validations -

extension CategoryFormViewModel {
    
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
}

// MARK: - Bindings -
extension CategoryFormViewModel {
    private func setupBindings() {
        setupOperationTypeBindings()
        setupEmojiBindings()
        setupCategoryBindings()
        setupPlottingBindings()
    }
    
    private func setupOperationTypeBindings() {
        operationTypeInputViewModel.onSelectionChanged = { [weak self] _ in
            guard let self = self else { return }
            
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
        
        categoryNameInputViewModel.onTextChanged = { [weak self] _ in
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
}


// MARK: - Helper -
extension CategoryFormViewModel {
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
