//
//  FeedbackFormViewController.swift
//  Vault
//
//  Created by Miguel Solans on 28/05/2026.
//

import UIKit
import AppUIKit
import CoreKit

final class FeedbackFormViewController: VaultBaseViewController {
    
    // MARK: - Dependencies
    private(set) var viewModel: FeedbackFormViewModel
    
    init(viewModel: FeedbackFormViewModel) {
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
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var typeInputView: OptionPickerInputView = {
        let view = OptionPickerInputView(
            viewModel: viewModel.typeInputViewModel,
            style: InputStyles.pickerStyle
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var messageInputView: TextInputView = {
        let view = TextInputView(
            viewModel: viewModel.messageInputViewModel,
            style: InputStyles.textFieldStyle
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var importanceInputView: OptionPickerInputView = {
        let view = OptionPickerInputView(
            viewModel: viewModel.importanceInputViewModel,
            style: InputStyles.pickerStyle
        )
        
        return view
    }()
    
    private lazy var contactSwitchInputView: SwitchInputView = {
        let view = SwitchInputView(
            viewModel: viewModel.contactSwitchInputViewModel,
            style: InputStyles.switchStyle
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view;
    }()
    
    private lazy var emailInputView: TextFieldInputView = {
        let view = TextFieldInputView(
            viewModel: viewModel.emailInputViewModel,
            style: InputStyles.textFieldStyle
        )
        
        view.isHidden = viewModel.emailInputHidden
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.apply(
            style: ButtonStyles.primary,
            title: "Send"
        )
        
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func setupUI() {
        view.backgroundColor = UIColor(resource: .background)
        
        setupNavigationItems()
        setupStackView()
        setupConstraints()
        setupActions()
    }
    
    private func updateUI() {
        if viewModel.isLoading {
            startLoading()
        } else {
            stopLoading()
        }
        
        emailInputView.isHidden = viewModel.emailInputHidden
        
    }
    
    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self else { return }
            
            updateUI()
        }
        
        viewModel.onSuccess = { [weak self] feedback in
            guard let self else { return }
            
            switch feedback {
            case .showAlert(let message):
                self.showSubmissionAlert(message: message)
                break
            case .silent:
                break
            }
            
            self.notifyFeedback(.error)
        }
        
        viewModel.onError = { [weak self] feedback in
            guard let self else { return }
            
            switch feedback {
            case .showAlert(let message):
                self.presentAlert(with:"Feedback Submitted", and: message)
                break
            case .silent:
                break
            }
            
            self.notifyFeedback(.error)
        }
    }
}

extension FeedbackFormViewController {
    private func setupStackView() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(typeInputView)
        stackView.addArrangedSubview(messageInputView)
        stackView.addArrangedSubview(importanceInputView)
        stackView.addArrangedSubview(contactSwitchInputView)
        stackView.addArrangedSubview(emailInputView)
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
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func setupNavigationItems() {
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle;
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
    }
}

extension FeedbackFormViewController {
    
    @objc private func closeTapped() {
        viewModel.didTapClose()
    }
    
    @objc private func saveTapped() {
        viewModel.didTapSave()
    }
}

extension FeedbackFormViewController {
    private func showSubmissionAlert(message: String) {
        
        self.presentAlert(
            with:"Feedback Submitted",
            and: message,
            onDismiss: { 
            self.viewModel.didTapClose()
        })
    }
}
