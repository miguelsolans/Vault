//
//  ImportOperationsViewController.swift
//  Vault
//
//  Created by Miguel Solans on 06/04/2026.
//

import UIKit
import AppUIKit

final class ImportOperationsViewController: UIViewController {
    
    var viewModel: ImportOperationsViewModel
    
    init(viewModel: ImportOperationsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private lazy var operationTypePickerInputView: OptionPickerInputView = {
        let view = OptionPickerInputView(viewModel: viewModel.operationTypeViewModel, style: InputStyles.pickerStyle)
        
        return view
    }();
    
    private lazy var categoryPickerInputView: OptionPickerInputView = {
        let view = OptionPickerInputView(viewModel: viewModel.categoryViewModel, style: InputStyles.pickerStyle)
        
        return view
    }();
    
    private lazy var amountPickerInputView: OptionPickerInputView = {
        let view = OptionPickerInputView(viewModel: viewModel.amountViewModel, style: InputStyles.pickerStyle)
        
        return view
    }();
    
    private lazy var descriptionPickerInputView: OptionPickerInputView = {
        let view = OptionPickerInputView(viewModel: viewModel.descriptionViewModel, style: InputStyles.pickerStyle)
        
        return view
    }();
    
    private lazy var datePickerInputView: OptionPickerInputView = {
        let view = OptionPickerInputView(viewModel: viewModel.dateViewModel, style: InputStyles.pickerStyle)
        
        return view
    }();
    
    private lazy var importButton: UIButton = {
        let button = UIButton(type: .system)
        button.apply(
            style: ButtonStyles.primary,
            title: NSLocalizedString("import_operations_import", tableName: "ImportOperations", comment: "")
        )
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var ignoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.apply(
            style: ButtonStyles.secondary,
            title: "Ignore"
        )
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("import_operations_map_fields", tableName: "ImportOperations", comment: "")
        navigationItem.subtitle = viewModel.subtitle
        
        setupScrollView()
        setupStackView()
        setupConstraints()
        
        importButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        ignoreButton.addTarget(self, action: #selector(ignoreTapped), for: .touchUpInside)
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(operationTypePickerInputView)
        stackView.addArrangedSubview(categoryPickerInputView)
        stackView.addArrangedSubview(amountPickerInputView)
        stackView.addArrangedSubview(descriptionPickerInputView)
        stackView.addArrangedSubview(datePickerInputView)
        stackView.addArrangedSubview(importButton)
        stackView.addArrangedSubview(ignoreButton)
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
}

extension ImportOperationsViewController {
    
    @objc private func saveTapped() {
        viewModel.didTapImport()
    }
    
    @objc private func ignoreTapped() {
        viewModel.didTapIgnore()
    }
    
    func onImportAlertDismiss(_ action: UIAlertAction) {
        self.viewModel.didDismissImportAlert()
    }
}


extension ImportOperationsViewController {
    func setupBindings() {
        viewModel.onImportResult = { [weak self] result in
            guard let self = self else { return }
            
            let message: String
            
            switch (result.successCount, result.failureCount) {
            case (_, 0):
                message = String(format: NSLocalizedString("import_operations_all_operations_imported", tableName: "ImportOperations", comment: ""), String(result.successCount))
                
            case (0, _):
                message = String(format: NSLocalizedString("import_operations_imported_failed", tableName: "ImportOperations", comment: ""), String(result.failureCount))
                
            default:
                message = String(format: NSLocalizedString("import_operations_some_operations_failed", tableName: "ImportOperations", comment: ""), result.successCount, String(result.failureCount))
            }
            
            let alert = UIAlertController(
                title: NSLocalizedString("import_operations_import_result", tableName: "ImportOperations", comment: ""),
                message: message,
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: NSLocalizedString("import_operations_ok", tableName: "ImportOperations", comment: ""), style: .default, handler: onImportAlertDismiss)
            
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
}
