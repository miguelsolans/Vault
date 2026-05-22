//
//  ReimbursementFormViewController.swift
//  Vault
//
//  Created by Miguel Solans on 30/04/2026.
//

import UIKit
import CoreKit
import AppUIKit

final class ReimbursementFormViewController: VaultBaseViewController {

    private(set) var viewModel: ReimbursementFormViewModel
    
    init(viewModel: ReimbursementFormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        
        view.axis = .vertical
        view.spacing = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var amountFeedbackView: FeedbackView = {
        let view = FeedbackView(
            viewModel: viewModel.amountFeedbackViewModel,
            style: FeedbackStyles.informativeFeedback
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var statusSegmentedView: SegmentedInputView = {
        let view = SegmentedInputView(
            viewModel: viewModel.statusInputViewModel,
            style: InputStyles.segmentedStyle
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var amountInputView: TextFieldInputView = {
        let view = TextFieldInputView(
            viewModel: viewModel.amountInputViewModel,
            style: InputStyles.textFieldStyle
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var notesInputView: TextFieldInputView = {
        let view = TextFieldInputView(
            viewModel: viewModel.notesInputViewModel,
            style: InputStyles.textFieldStyle
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var vaultInputView: OptionPickerInputView = {
        let view = OptionPickerInputView(
            viewModel: viewModel.depositVaultViewModel,
            style: InputStyles.pickerStyle
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var depositFeedbackView: FeedbackView = {
        let view = FeedbackView(
            viewModel: viewModel.depositFeedbackViewModel,
            style: FeedbackStyles.informativeFeedback
        )
        
        view.isHidden = viewModel.depositFeedbackHidden
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var categoryInputView: OptionPickerInputView = {
        let view = OptionPickerInputView(
            viewModel: viewModel.depositCategoryViewModel,
            style: InputStyles.pickerStyle
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.apply(
            style: ButtonStyles.primary,
            title: "Save"
        )
        
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
        view.backgroundColor = .systemBackground
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
        
        setupScrollView()
        setupStackView()
        setupConstraints()
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func updateUI() {
        
        depositFeedbackView.isHidden = viewModel.depositFeedbackHidden
    }
    
    override func setupBindings() {
        
        viewModel.updateUI = { [weak self] in
            guard let self else { return }
            
            self.updateUI()
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

extension ReimbursementFormViewController {
    private func setupScrollView() {
        view.addSubview(scrollView)
    }
    
    private func setupStackView() {
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(amountFeedbackView)
        stackView.addArrangedSubview(statusSegmentedView)
        stackView.addArrangedSubview(amountInputView)
        stackView.addArrangedSubview(notesInputView)
        stackView.addArrangedSubview(vaultInputView)
        stackView.addArrangedSubview(depositFeedbackView)
        stackView.addArrangedSubview(categoryInputView)
        stackView.addArrangedSubview(saveButton)
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

extension ReimbursementFormViewController {
    @objc private func saveButtonTapped() {
        viewModel.saveTapped()
    }
}
