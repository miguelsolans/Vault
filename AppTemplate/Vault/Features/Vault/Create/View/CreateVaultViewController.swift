//
//  CreateVaultViewController.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import UIKit
import AppUIKit

class CreateVaultViewController: UIViewController {
    
    var viewModel: CreateVaultViewModel
    
    init(viewModel: CreateVaultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private lazy var nameInputView: TextFieldInputView = {
        
        let inputView = TextFieldInputView(viewModel: viewModel.nameInputViewModel, style: InputStyles.textFieldStyle)
        inputView.translatesAutoresizingMaskIntoConstraints = false
        return inputView
    }()
    
    private lazy var depositSwitchInputView: SwitchInputView = {
        let view = SwitchInputView(viewModel: viewModel.depositSwitchViewModel, style: InputStyles.switchStyle)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var depositInputView: TextFieldInputView = {
        
        let inputView = TextFieldInputView(viewModel: viewModel.depositInputViewModel, style: InputStyles.textFieldStyle)
        inputView.translatesAutoresizingMaskIntoConstraints = false
        
        inputView.isHidden = !self.viewModel.isInitialDepositOn
        
        return inputView
    }()
    
    private lazy var uploadFileSwitchView: SwitchInputView = {
        
        let view = SwitchInputView(viewModel: viewModel.importFileSwitchViewModel, style: InputStyles.switchStyle)
        
        return view
    }()
    
    private lazy var uploadFilePickerView: FilePickerInputView = {
        
        let view = FilePickerInputView(viewModel: viewModel.importFileViewModel, style: InputStyle())
        
        return view
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.apply(
            style: ButtonStyles.primary,
            title: String(localized: LocalizedStringResource.CreateVault.save)
        )
        
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupStackView()
        setupConstraints()
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(nameInputView)
        stackView.addArrangedSubview(depositSwitchInputView)
        stackView.addArrangedSubview(depositInputView)
        stackView.addArrangedSubview(uploadFileSwitchView)
        stackView.addArrangedSubview(uploadFilePickerView)
        stackView.addArrangedSubview(saveButton)
        
        uploadFileSwitchView.isHidden = viewModel.isEditing
        
        uploadFilePickerView.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    // MARK: - Actions
    @objc private func saveTapped() {
        
        viewModel.didTapSave()
    }
}

// MARK: - Bindings

extension CreateVaultViewController {
    func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            
            self.depositInputView.isHidden = !self.viewModel.isInitialDepositOn
            self.uploadFilePickerView.isHidden = !self.viewModel.isImportOn
            
        }
        
        viewModel.onImportResult = { [weak self] result in
            guard let self = self else { return }
            
            let message: String
            
            switch (result.successCount, result.failureCount) {
            case (_, 0):
                message = "All \(result.successCount) operations imported successfully."
                
            case (0, _):
                message = "Import failed. \(result.failureCount) rows could not be processed."
                
            default:
                message = """
                    Imported \(result.successCount) operations.
                    \(result.failureCount) failed to import.
                    """
            }
            
            let alert = UIAlertController(
                title: "Import Result",
                message: message,
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: onImportAlertDismiss)
            
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
}

extension CreateVaultViewController {
    func onImportAlertDismiss(_ action: UIAlertAction) {
        self.viewModel.onImportAlertDismiss()
    }
}
