//
//  FeedbackFormViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 28/05/2026.
//

import Foundation
import CoreKit
import AppUIKit
import VaultCore

protocol FeedbackFormViewModelDelegate: AnyObject {
    func didTapClose(_ viewModel: FeedbackFormViewModel)
}

final class FeedbackFormViewModel: NSObject {
    
    weak var delegate: FeedbackFormViewModelDelegate?
    
    // MARK: - Dependencies
    
    private let feedbackUseCase: CreateFeedbackUseCase
    
    init(
        feedbackUseCase: CreateFeedbackUseCase
    ) {
        self.feedbackUseCase = feedbackUseCase
        self.isLoading = false
        super.init()
        setupBindings()
    }
    
    // MARK: - UI State
    
    private(set) var title: String = "";
    
    private(set) var subtitle: String = "";
    
    public lazy var typeInputViewModel: OptionInputViewModel = {
        let viewModel = OptionInputViewModel(
            title: "Type",
            placeholder: "What happened",
            options: [ "Bug", "Idea", "Confusing", "Other" ],
            isMandatory: true
        )
        
        return viewModel
    }()
    
    public lazy var messageInputViewModel: TextInputViewModel = {
        
        let viewModel = TextInputViewModel(
            title: "Tell us more",
            isEditable: true,
            placeholder: "Enter your message",
            subtitle: nil,
            isMandatory: true
        )
        
        return viewModel;
    }()
    
    public lazy var importanceInputViewModel: OptionInputViewModel = {
        let viewModel = OptionInputViewModel(
            title: "Importance",
            placeholder: "How important is this?",
            options: [ "Low", "Medium", "High" ],
            isMandatory: true
        )
        
        return viewModel
    }()
    
    public lazy var contactSwitchInputViewModel: SwitchInputViewModel = {
        
        let viewModel = SwitchInputViewModel(
            title: "Contact",
            isEditable: true,
            placeholder: "You can contact me about this",
            isMandatory: true
        )
        
        return viewModel
    }()
    
    public lazy var emailInputViewModel: TextFieldInputViewModel = {
        
        let viewModel = TextFieldInputViewModel(
            title: "E-mail",
            isEditable: true,
            placeholder: "Enter e-mail",
            subtitle: nil,
            textType: .text,
            isMandatory: false
        )
        
        return viewModel;
    }()
    
    public var emailInputHidden: Bool {
        return !contactSwitchInputViewModel.isOn
    }
    
    public var isLoading: Bool {
        didSet {
            updateUI?()
        }
    }
    
    // MARK: - Bindings
    
    public var updateUI: (() -> Void)?
    
    public var onSuccess: ((ViewModelFeedback) -> Void)?
    
    public var onError: ((ViewModelFeedback) -> Void)?
}

// MARK: - Actions

extension FeedbackFormViewModel {
    public func didTapSave() {
        guard validateInputs() else {
            onError?(.silent)
            return
        }
        
        createFeedback()
    }
    
    public func didTapClose() {
        delegate?.didTapClose(self)
    }
}

// MARK: - Data
extension FeedbackFormViewModel {
    private func createFeedback() {
        
        guard let type = typeInputViewModel.selectedOption,
              let importance = importanceInputViewModel.selectedOption
        else {
            return
        }
        
        // TODO: Start loading
        isLoading = true
        
        let request = CreateFeedbackRequest(
            type: type,
            message: messageInputViewModel.inputText,
            importance: importance,
            contact: emailInputViewModel.inputText,
            appVersion: AppConfig.appVersion,
            iOSVersion: AppConfig.systemVersion
        )
        
        Task {
            do {
                
                _ = try await feedbackUseCase.execute(request)
                
                await MainActor.run {
                    isLoading = false
                    
                    onError?(.showAlert(message: "Thank you very much for the feedback during the testing phase. We will take a look into your request soon."))
                }
                
            } catch {
                onError?(.showAlert(message: "There was an error submitting your feedback. Please try again."))
            }
        }
    }
}

// MARK: - Validations

extension FeedbackFormViewModel {
    private func validateInputs() -> Bool {
        var isValid = true
        
        if !validateType() {
            isValid = false
        }
        
        if !validateMessage() {
            isValid = false
        }
        
        if !validateImportance() {
            isValid = false
        }
        
        return isValid
    }
    
    private func validateType() -> Bool {
        return FormValidator.validateRequired(
            typeInputViewModel,
            message: "Type can't be empty"
        )
    }
    
    private func validateMessage() -> Bool {
        return FormValidator.validateRequired(
            messageInputViewModel,
            message: "Message can't be empty"
        )
    }
    
    private func validateImportance() -> Bool {
        return FormValidator.validateRequired(
            importanceInputViewModel,
            message: "Importance can't be empty"
        )
    }
}

// MARK: - Bindings

extension FeedbackFormViewModel {
    
    private func setupBindings() {
        setupTypeBindings()
        setupMessageBindings()
        setupImportanceBindings()
        setupContactBindings()
        setupEmailBindings()
    }
    
    private func setupTypeBindings() {
        typeInputViewModel.onSelectionChanged = { [weak self] _ in
            guard let self else { return }
            
            self.typeInputViewModel.feedback = .none
        }
    }
    
    private func setupMessageBindings() {
        messageInputViewModel.onBeginEditing = { [weak self] in
            guard let self else { return }
            
            self.messageInputViewModel.feedback = .none
        }
    }
    
    private func setupImportanceBindings() {
        typeInputViewModel.onSelectionChanged = { [weak self] _ in
            guard let self else { return }
            
            self.typeInputViewModel.feedback = .none
        }
    }
    
    private func setupContactBindings() {
        contactSwitchInputViewModel.onValueChanged = { [weak self] _ in
            guard let self else { return }
            
            self.contactSwitchInputViewModel.feedback = .none
            
            self.updateUI?()
        }
    }
    
    private func setupEmailBindings() {
        emailInputViewModel.onBeginEditing = { [weak self] in
            guard let self else { return }
            
            self.messageInputViewModel.feedback = .none
        }
    }
}

