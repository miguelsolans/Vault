//
//  VaultFormViewController.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import UIKit
import AppUIKit
import CoreKit

final class VaultFormViewController: VaultBaseViewController {
    
    // MARK: - Dependencies
    private(set) var viewModel: VaultFormViewModel
    
    init(
        viewModel: VaultFormViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 16
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var nameInputView: TextFieldInputView = {
        let view = TextFieldInputView(viewModel: viewModel.nameInputViewModel, style: InputStyles.textFieldStyle)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var depositSwitchInputView: SwitchInputView = {
        let view = SwitchInputView(viewModel: viewModel.depositSwitchViewModel, style: InputStyles.switchStyle)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var depositInputView: TextFieldInputView = {
        let view = TextFieldInputView(viewModel: viewModel.depositInputViewModel, style: InputStyles.textFieldStyle)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.isHidden = self.viewModel.isInitialDepositHidden
        
        return view
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
        setupUI()
        setupBindings()
    }
    
    override func setupUI() {
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupStackView()
        setupConstraints()
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self else { return }
            
            self.depositInputView.isHidden = self.viewModel.isInitialDepositHidden
            self.uploadFilePickerView.isHidden = self.viewModel.isImportHidden
        }
        
        viewModel.onSuccess = { [weak self] _ in
            guard let self else { return }
            
            self.notifyFeedback(.success)
        }
        
        viewModel.onError = { [weak self] error in
            guard let self else { return }
            
            switch error {
            case .showAlert(let message):
                self.presentAlert(with:"Error", and: message)

            case .silent:
                break
            }
            
            self.notifyFeedback(.error)
        }
    }
}

// MARK: - UI Setup

extension VaultFormViewController {
    
    private func setupScrollView() {
        view.addSubview(scrollView)
    }
    
    private func setupStackView() {
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(nameInputView)
        stackView.addArrangedSubview(depositSwitchInputView)
        stackView.addArrangedSubview(depositInputView)
        stackView.addArrangedSubview(uploadFileSwitchView)
        stackView.addArrangedSubview(uploadFilePickerView)
        stackView.addArrangedSubview(saveButton)
        
        uploadFileSwitchView.isHidden = viewModel.isFileUploadHidden
        
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
}

// MARK: - Actions

extension VaultFormViewController {
    
    @objc private func saveTapped() {
        viewModel.didTapSave()
    }
}
