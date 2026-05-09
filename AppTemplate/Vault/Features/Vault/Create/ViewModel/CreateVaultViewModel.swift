//
//  CreateVaultViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import UIKit
import AppUIKit
import VaultCore

protocol CreateVaultViewModelDelegate: AnyObject {
    func didCreateVault(_ vault: VaultDTO, andFileURL fileURL: URL?)
    func didUpdateVault(_ vault: VaultDTO)
}

class CreateVaultViewModel: NSObject {
    
    weak var delegate: CreateVaultViewModelDelegate?
    
    // MARK: - Dependencies
    
    private let createUseCase: CreateVaultUseCase
    
    private let editUseCase: EditVaultUseCase
    
    private let vaultToEdit: VaultDTO?
    
    init(createUseCase: CreateVaultUseCase, editUseCase: EditVaultUseCase, vaultToEdit: VaultDTO?) {
        self.createUseCase = createUseCase
        self.editUseCase = editUseCase
        self.vaultToEdit = vaultToEdit
        super.init()
        self.setupBindings()
    }
    
    // MARK: - State
    
    public var isEditing: Bool {
        return vaultToEdit != nil
    }
    
    // MARK: - Input fields
    
    lazy var nameInputViewModel: TextFieldInputViewModel = {
        let viewModel = TextFieldInputViewModel(
            title: NSLocalizedString("create_vault_name", tableName: "CreateVault", comment: ""),
            isEditable: true,
            placeholder: NSLocalizedString("create_vault_enter_name", tableName: "CreateVault", comment: ""),
            subtitle: nil,
            inputText: vaultToEdit?.name ?? "",
            textType: .text,
            isMandatory: true
        )
        
        return viewModel
    }()
    
    lazy var depositSwitchViewModel: SwitchInputViewModel = {
        
        if let vaultToEdit, vaultToEdit.initialDeposit > 0 {
            self.isInitialDepositOn = true
        }
        
        let viewModel = SwitchInputViewModel(
            title: "Initial deposit",
            isOn: self.isInitialDepositOn,
            isEditable: true,
            placeholder: "Include an initial deposit amount"
        )
        
        return viewModel
    }()
    
    lazy var depositInputViewModel: TextFieldInputViewModel = {
        
        var amount = ""
        
        if let vaultToEdit {
            amount = LocalizedDecimalFormatter.init(numberStyle: .currency)
                .string(from: vaultToEdit.initialDeposit) ?? ""
        }
        
        let viewModel = TextFieldInputViewModel(
            title: NSLocalizedString("create_vault_initial_deposit", tableName: "CreateVault", comment: ""),
            isEditable: true,
            placeholder: NSLocalizedString("create_vault_enter_amount", tableName: "CreateVault", comment: ""),
            subtitle: nil,
            inputText: amount,
            textType: .currency("EUR"),
            isMandatory: false
        )
        
        return viewModel
    }()
    
    lazy var importFileSwitchViewModel: SwitchInputViewModel = {
        let viewModel = SwitchInputViewModel(
            title: String(localized: LocalizedStringResource.CreateVault.importOperations),
            isOn: false,
            isEditable: !isEditing,
            placeholder: String(localized: LocalizedStringResource.CreateVault.importFromCsvFile),
            subtitle: nil,
            isMandatory: false
        )
        
        return viewModel
    }()
    
    lazy var importFileViewModel: FilePickerInputViewModel = {
        let viewModel = FilePickerInputViewModel(
            title: String(localized: LocalizedStringResource.CreateVault.csvFile),
            isEditable: true,
            allowedContentTypes: [ .commaSeparatedText ],
            placeholder: String(localized: LocalizedStringResource.CreateVault.save),
            subtitle: nil,
            isMandatory: false
        )
        
        return viewModel
    }()
    
    // MARK: - State
    
    public var isImportOn: Bool = false {
        didSet { updateUI?() }
    }
    
    public var isInitialDepositOn: Bool = false {
        didSet { updateUI?() }
    }
    
    // MARK: - Bindings
    var updateUI: (() -> Void)?
    
    var onImportResult: ((ImportOperationsResponse) -> Void)?
}

// MARK: - Actions

extension CreateVaultViewModel {
    
    func didTapSave() {
        
        if !validateInputs() {
            updateUI?()
            return
        }
        
        self.saveVault();
    }
    
    
    
    func onImportAlertDismiss() {
        
    }
}

extension CreateVaultViewModel {
    
    func saveVault() {
        
        let amount = LocalizedDecimalFormatter()
            .double(from: depositInputViewModel.inputText) ?? 0.0
        
        if let vaultToEdit = vaultToEdit {
            updateVault(
                vault: vaultToEdit,
                newTitle: nameInputViewModel.inputText,
                newInitialDeposit: amount,
                newCurrencyCode: "EUR"
            )
            
            return
        }
        
        createVault(
            title: nameInputViewModel.inputText,
            initialDeposit: amount,
            currencyCode: "EUR"
        )
    }
    
    func createVault(title: String, initialDeposit: Double, currencyCode: String) {
        
        do {
            
            let request = CreateVaultRequest(
                title: title,
                initialDeposit: initialDeposit,
                currencyCode: currencyCode,
                importFileURL: importFileViewModel.selectedFileURL
            )
            
            let response = try createUseCase.execute(request: request)
            
            
            delegate?.didCreateVault(response.vault, andFileURL: response.importFileURL);
        } catch {
            // TODO: Present error?
        }
    }
    
    func updateVault(vault: VaultDTO, newTitle: String, newInitialDeposit: Double, newCurrencyCode: String) {
        
        do {
            
            let request = EditVaultRequest(
                id: vault.id,
                newTitle: newTitle,
                newInitialDeposit: newInitialDeposit,
                newCurrencyCode: newCurrencyCode
            )
            
            let response = try editUseCase.execute(request: request)
            
            delegate?.didUpdateVault(response.vault)
            
        } catch {
            // TODO: Present error?
        }
    }
}

// MARK: - Form validations

extension CreateVaultViewModel {
    fileprivate func validateInputs() -> Bool {
        var isValid = true
        
        if !validateName() {
            isValid = false
        }
        
        if !validateDepositIfNeeded() {
            isValid = false
        }

        if !validateFileImportIfNeeded() {
            isValid = false
        }
        
        return isValid
    }
    
    private func validateName() -> Bool {
        
        if nameInputViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            nameInputViewModel.feedback = .error(NSLocalizedString("create_vault_name_required", tableName: "CreateVault", comment: ""))
            return false
        } else {
            nameInputViewModel.feedback = .none
        }
        
        return true
    }
    
    private func validateDepositIfNeeded() -> Bool {
        
        if !depositInputViewModel.inputText.isEmpty {
            
            guard let _ = LocalizedDecimalFormatter()
                .double(from: depositInputViewModel.inputText) else {
                depositInputViewModel.feedback = .error(NSLocalizedString("create_vault_invalid_amount", tableName: "CreateVault", comment: ""))
                return false
            }
            
            depositInputViewModel.feedback = .none
            
        } else {
            depositInputViewModel.feedback = .none
        }
        
        return true
    }
    
    private func validateFileImportIfNeeded() -> Bool {
        
        if isImportOn {
            if importFileViewModel.selectedFileURL == nil {
                importFileViewModel.feedback = .error(NSLocalizedString("create_vault_file_required", tableName: "CreateVault", comment: ""))
                return false
            } else {
                importFileViewModel.feedback = .none
            }
        } else {
            importFileViewModel.feedback = .none
        }
        
        return true
    }
}

extension CreateVaultViewModel {
    private func setupBindings() {
        setupNameInputBindings()
        setupDepositSwitchBindings()
        setupDepositInputBindings()
        setupImportFileSwitchBindings()
        setupImportFileBindings()
    }
    
    private func setupNameInputBindings() {
        nameInputViewModel.onBeginEditing = { [weak self] in
            guard let self = self else { return }
            
            self.nameInputViewModel.feedback = .none
        }
        
        nameInputViewModel.onEndEditing = { [weak self] in
            guard let self = self else { return }
            
            self.nameInputViewModel.feedback = .none
        }
    }
    
    private func setupDepositSwitchBindings() {
        depositSwitchViewModel.onValueChanged = { [weak self] on in
            guard let self = self else { return }
            self.isInitialDepositOn = on
        }
    }
    
    private func setupDepositInputBindings() {
        depositInputViewModel.onBeginEditing = { [weak self] in
            guard let self = self else { return }
            self.depositInputViewModel.feedback = .none
        }
    }
    
    private func setupImportFileSwitchBindings() {
        
        importFileSwitchViewModel.onValueChanged = { [weak self] on in
            guard let self = self else { return }
            
            self.isImportOn = on
            
            if !on {
                self.importFileViewModel.selectedFileURL = nil
            }
        }
    }
    
    private func setupImportFileBindings() {
        importFileViewModel.onBeginChoosing = { [weak self] in
            guard let self = self else { return }
            self.importFileViewModel.feedback = .none
        }
        
        importFileViewModel.onEndChoosing = { [weak self] in
            guard let self = self else { return }
            self.importFileViewModel.feedback = .none
        }
    }
}
