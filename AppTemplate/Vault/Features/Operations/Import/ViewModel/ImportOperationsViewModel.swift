//
//  ImportOperationsViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 06/04/2026.
//

import UIKit
import AppUIKit
import VaultCore

protocol ImportOperationsViewModelDelegate: AnyObject {
    func viewModelDidImportOperations(_ viewModel: ImportOperationsViewModel)
    func viewModelDidIgnoreImportOperations(_ viewModel: ImportOperationsViewModel)
}

final class ImportOperationsViewModel: NSObject {
    
    weak var delegate: ImportOperationsViewModelDelegate?
    
    // MARK: - Dependencies
    
    fileprivate let vault: VaultDTO
    
    fileprivate let fileURL: URL
    
    init(vault: VaultDTO, fileURL: URL) {
        self.vault = vault
        self.fileURL = fileURL
        super.init()
        loadData()
        setupBindings()
    }
    
    // MARK: - State

    var subtitle: String {
        get { vault.name }
    }
    
    private(set) var csvHeader: [String] = []
    
    private(set) var csvContent: [[String: String]] = []
    
    // MARK: - Input ViewModel's
    
    lazy var operationTypeViewModel: OptionInputViewModel = {
        let viewModel = OptionInputViewModel(title: NSLocalizedString("import_operations_operation_type", tableName: "ImportOperations", comment: ""), options: csvHeader)
        
        return viewModel;
    }()
    
    lazy var categoryViewModel: OptionInputViewModel = {
        let viewModel = OptionInputViewModel(title: NSLocalizedString("import_operations_category", tableName: "ImportOperations", comment: ""), options: csvHeader)
        
        return viewModel;
    }()
    
    lazy var amountViewModel: OptionInputViewModel = {
        let viewModel = OptionInputViewModel(title: NSLocalizedString("import_operations_amount", tableName: "ImportOperations", comment: ""), options: csvHeader)
        
        return viewModel;
    }()
    
    lazy var descriptionViewModel: OptionInputViewModel = {
        let viewModel = OptionInputViewModel(title: NSLocalizedString("import_operations_description", tableName: "ImportOperations", comment: ""), options: csvHeader)
        
        return viewModel;
    }()
    
    lazy var dateViewModel: OptionInputViewModel = {
        let viewModel = OptionInputViewModel(title: NSLocalizedString("import_operations_date", tableName: "ImportOperations", comment: ""), options: csvHeader)
        
        return viewModel;
    }()
    
    // MARK: - Bindings
    var updateUI: (() -> Void)?
    
    var onImportResult: ((ImportOperationsResponse) -> Void)?
}

extension ImportOperationsViewModel {
    fileprivate func loadData() {
        
        let csvConfiguration = CSVConfiguration(
            separator: ";",
            hasHeader: true
        )
        
        let csvReader = CSVReader(fileURL: fileURL, configuration: csvConfiguration)
        
        
        do {
            let data = try csvReader.readData()
            
            csvHeader = data.header
            
            csvContent = data.rows
            
        } catch {
            // TODO: Present error?
        }
    }
}

extension ImportOperationsViewModel {
    public func didTapImport() {
        
        if !validateInputs() {
            return
        }
        
        let fieldMapping = ImportFieldMapping(
            date: self.operationTypeViewModel.selectedOption,
            amount: self.categoryViewModel.selectedOption,
            type: self.amountViewModel.selectedOption,
            category: self.descriptionViewModel.selectedOption,
            description: self.dateViewModel.selectedOption
        )
        
        let request = ImportOperationsRequest(
            vaultID: vault.id,
            csvData: csvContent,
            fieldMapping: fieldMapping
        )
        
        let useCase = DependenciesContainer.shared.getImportOperationsUseCase()
        
        do {
            let result = try useCase.execute(request)
            
            
            onImportResult?(result)
        } catch {
            // TODO: Present error
        }
    }
    
    public func didTapIgnore() {
        delegate?.viewModelDidIgnoreImportOperations(self)
    }
    
    public func didDismissImportAlert() {
        
        delegate?.viewModelDidImportOperations(self)
    }
}

// MARK: - Form validations

extension ImportOperationsViewModel {
    
    fileprivate func validateInputs() -> Bool {
        var isValid = true
        
        if !validateOperationType() {
            isValid = false
        }
        
        if !validateCategory() {
            isValid = false
        }
        
        if !validateAmount() {
            isValid = false
        }
        
        if !validateDescription() {
            isValid = false
        }
        
        if !validateDate() {
            isValid = false
        }
        
        return isValid
    }
    
    private func validateOperationType() -> Bool {
        
        if operationTypeViewModel.selectedOption == nil {
            operationTypeViewModel.feedback = .error(NSLocalizedString("import_operations_select_an_option", tableName: "ImportOperations", comment: ""))
            return false
        }
        
        return true;
    }
    
    private func validateCategory() -> Bool {
        
        if categoryViewModel.selectedOption == nil {
            categoryViewModel.feedback = .error(NSLocalizedString("import_operations_select_an_option", tableName: "ImportOperations", comment: ""))
            return false
        }
        
        return true;
    }
    
    private func validateAmount() -> Bool {
        
        if amountViewModel.selectedOption == nil {
            amountViewModel.feedback = .error(NSLocalizedString("import_operations_select_an_option", tableName: "ImportOperations", comment: ""))
            return false
        }
        
        return true;
    }
    
    private func validateDescription() -> Bool {
        
        if descriptionViewModel.selectedOption == nil {
            descriptionViewModel.feedback = .error(NSLocalizedString("import_operations_select_an_option", tableName: "ImportOperations", comment: ""))
            return false
        }
        
        return true;
    }
    
    private func validateDate() -> Bool {
        
        if dateViewModel.selectedOption == nil {
            dateViewModel.feedback = .error(NSLocalizedString("import_operations_select_an_option", tableName: "ImportOperations", comment: ""))
            return false
        }
        
        return true;
    }
}

extension ImportOperationsViewModel {
    private func setupBindings() {
        setupOperationTypeBindings()
        setupCategoryBindings()
        setupAmountBindings()
        setupDescriptionBindings()
        setupDateBindings()
    }
    
    private func setupOperationTypeBindings() {
        operationTypeViewModel.onBeginChoosing = { [weak self] in
            guard let self = self else { return }
            self.operationTypeViewModel.feedback = .none
        }
    }
    
    private func setupCategoryBindings() {
        categoryViewModel.onBeginChoosing = { [weak self] in
            guard let self = self else { return }
            self.categoryViewModel.feedback = .none
        }
    }
    
    private func setupAmountBindings() {
        amountViewModel.onBeginChoosing = { [weak self] in
            guard let self = self else { return }
            self.amountViewModel.feedback = .none
        }
    }
    
    private func setupDescriptionBindings() {
        descriptionViewModel.onBeginChoosing = { [weak self] in
            guard let self = self else { return }
            self.descriptionViewModel.feedback = .none
        }
    }
    
    private func setupDateBindings() {
        dateViewModel.onBeginChoosing = { [weak self] in
            guard let self = self else { return }
            self.dateViewModel.feedback = .none
        }
    }
}
