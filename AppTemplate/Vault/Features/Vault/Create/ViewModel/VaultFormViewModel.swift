//
//  VaultFormViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import UIKit
import CoreKit
import AppUIKit
import VaultCore

protocol VaultFormViewModelDelegate: AnyObject {
    func didCreateVault(_ viewModel: VaultFormViewModel, vault: VaultDTO, with fileURL: URL?)
    func didUpdateVault(_ viewModel: VaultFormViewModel, vault: VaultDTO)
}

final class VaultFormViewModel: NSObject {
    
    weak var delegate: VaultFormViewModelDelegate?
    
    // MARK: - Dependencies
    
    private let createUseCase: CreateVaultUseCase
    
    private let editUseCase: EditVaultUseCase
    
    private let vaultToEdit: VaultDTO?
    
    init(
        createUseCase: CreateVaultUseCase,
        editUseCase: EditVaultUseCase,
        vaultToEdit: VaultDTO?
    ) {
        self.createUseCase = createUseCase
        self.editUseCase = editUseCase
        self.vaultToEdit = vaultToEdit
        super.init()
        self.setupBindings()
    }
    
    // MARK: - State State
    
    public var title: String {
        vaultToEdit != nil ? L10n.EditVault.pageTitle : L10n.CreateVault.pageTitle
    }
    
    public var subtitle: String {
        L10n.CreateVault.pageSubtitle
    }
    
    private var isEditing: Bool {
        return vaultToEdit != nil
    }
    
    public var isFileUploadHidden: Bool {
        return true
    }
    
    public var isInitialDepositHidden: Bool {
        return !depositSwitchViewModel.isOn
    }
    
    public var isImportHidden: Bool {
        return true
    }
    
    // MARK: - Input fields
    
    lazy var nameInputViewModel: TextFieldInputViewModel = {
        let viewModel = TextFieldInputViewModel(
            title: L10n.CreateVault.name,
            isEditable: true,
            placeholder: L10n.CreateVault.enterName,
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
            title: L10n.CreateVault.initialAmount,
            isOn: self.isInitialDepositOn,
            isEditable: true,
            placeholder: L10n.CreateVault.setupInitialAmount
        )
        
        return viewModel
    }()
    
    lazy var depositInputViewModel: TextFieldInputViewModel = {
        
        var amount = ""
        
        if let vaultToEdit, vaultToEdit.initialDeposit > 0 {
            amount = LocalizedDecimalFormatter.init(numberStyle: .decimal)
                .string(from: vaultToEdit.initialDeposit) ?? ""
        }
        
        let viewModel = TextFieldInputViewModel(
            title: L10n.CreateVault.initialAmount,
            isEditable: true,
            placeholder: L10n.CreateVault.enterInitialAmount,
            subtitle: nil,
            inputText: amount,
            textType: .currency("EUR"),
            isMandatory: false
        )
        
        return viewModel
    }()
    
    lazy var importFileSwitchViewModel: SwitchInputViewModel = {
        let viewModel = SwitchInputViewModel(
            title: L10n.CreateVault.importOperations,
            isOn: false,
            isEditable: !isEditing,
            placeholder: L10n.CreateVault.importFromCsv,
            subtitle: nil,
            isMandatory: false
        )
        
        return viewModel
    }()
    
    lazy var importFileViewModel: FilePickerInputViewModel = {
        let viewModel = FilePickerInputViewModel(
            title: L10n.CreateVault.csvFile,
            isEditable: true,
            allowedContentTypes: [ .commaSeparatedText ],
            placeholder: "",
            subtitle: nil,
            isMandatory: false
        )
        
        return viewModel
    }()
    
    // MARK: - State
    
    private var isImportOn: Bool = false {
        didSet { updateUI?() }
    }
    
    private var isInitialDepositOn: Bool = false {
        didSet { updateUI?() }
    }
    
    // MARK: - Bindings
    public var updateUI: (() -> Void)?
    
    public var onSuccess: ((ViewModelFeedback) -> Void)?
    
    public var onError: ((ViewModelFeedback) -> Void)?
}

// MARK: - Actions

extension VaultFormViewModel {
    
    func didTapSave() {
        
        if !validateInputs() {
            updateUI?()
            return
        }
        
        self.saveVault();
    }
}

// MARK: - Data

extension VaultFormViewModel {
    
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
            
            onSuccess?(.silent)
            
            delegate?.didCreateVault(self, vault: response.vault, with: response.importFileURL)
            
        } catch VaultError.vaultAlreadyExists(let name) {
            
            nameInputViewModel.feedback = .error(L10n.CreateVault.vaultWithNameAlreadyExists)
            onError?(.silent)
            
        } catch {
            onError?(.showAlert(message: L10n.CreateVault.errorCreatingVault))
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
            
            onSuccess?(.silent)
            
            delegate?.didUpdateVault(self, vault: response.vault)
            
        } catch VaultError.vaultAlreadyExists(let name) {
            
            nameInputViewModel.feedback = .error(L10n.EditVault.vaultWithNameAlreadyExists)
            onError?(.silent)
            
        } catch {
            onError?(.showAlert(message: L10n.EditVault.errorUpdatingVault))
        }
    }
}

// MARK: - Validations

extension VaultFormViewModel {
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
            nameInputViewModel.feedback = .error(L10n.CreateVault.nameRequired)
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
                depositInputViewModel.feedback = .error(L10n.CreateVault.initialAmountRequired)
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
                importFileViewModel.feedback = .error(L10n.CreateVault.fileRequired)
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

// MARK: - Bindings

extension VaultFormViewModel {
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
            
            if !on {
                self.depositInputViewModel.inputText = ""
            }
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
