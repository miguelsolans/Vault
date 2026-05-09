//
//  SampleViewController.swift
//  Vault
//
//  Created by Miguel Solans on 30/03/2026.
//

import UIKit
import AppUIKit

class SampleViewController: UIViewController {
    
    var viewModel: SampleViewModel
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    init(viewModel: SampleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.screenTitle
        navigationItem.subtitle = viewModel.screenSubtitle
        view.backgroundColor = .systemBackground
        
        setupLayout()
        setupContent()
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 12
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 12),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -12),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -12),
            
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -24)
        ])
    }
    
    private func setupContent() {
        // Date input
        let dateViewModel = DatePickerInputViewModel(
            title: "Title",
            selectedDate: Date(),
            isEditable: true,
            placeholder: "Placeholder",
            subtitle: "Subtitle",
            isMandatory: true
        )
        dateViewModel.feedback = .info("Informative bottom label")
        
        let dateInputView = DatePickerInputView(
            viewModel: dateViewModel,
            style: InputStyles.datePickerStyle
        )
        
        // Currency input
        let currencyViewModel = TextFieldInputViewModel(
            title: "Title",
            isEditable: true,
            placeholder: "Placeholder",
            subtitle: "Subtitle",
            inputText: "",
            textType: .currency("EUR"),
            isMandatory: true
        )
        currencyViewModel.feedback = .success("Success bottom label")
        
        let currencyInputView = TextFieldInputView(
            viewModel: currencyViewModel,
            style: InputStyles.textFieldStyle
        )
        
        // Segmented
        let segmentedViewModel = SegmentedInputViewModel(
            title: "Title",
            options: ["Income", "Expense"],
            selectedIndex: 1,
            isEditable: true,
            placeholder: "Placeholder",
            subtitle: "Subtitle",
            isMandatory: false
        )
        
        let segmentedInputView = SegmentedInputView(
            viewModel: segmentedViewModel,
            style: InputStyles.segmentedStyle
        )
        
        // Picker
        let pickerViewModel = OptionInputViewModel(
            title: "Title",
            options: ["Option A", "Option B", "Option C"]
        )
        pickerViewModel.feedback = .warning("Warning bottom label")
        
        let pickerInputView = OptionPickerInputView(
            viewModel: pickerViewModel,
            style: InputStyles.pickerStyle
        )
        
        // Switch
        let switchViewModel = SwitchInputViewModel(
            title: "Title",
            isOn: true,
            isEditable: false,
            placeholder: "Placeholder",
            subtitle: "Subtitle",
            isMandatory: false
        )
        
        let switchInputView = SwitchInputView(
            viewModel: switchViewModel,
            style: InputStyles.switchStyle
        )
        
        // Buttons
        let primaryButton = UIButton(type: .system)
        primaryButton.apply(style: ButtonStyles.primary, title: "Primary button")
        
        let secondaryButton = UIButton(type: .system)
        secondaryButton.apply(style: ButtonStyles.secondary, title: "Secondary button")
        
        let destructiveButton = UIButton(type: .system)
        destructiveButton.apply(style: ButtonStyles.destructive, title: "Destructive button")
        
        // Feedback - informative
        let feedbackViewModel = FeedbackViewModel(
            title: "Informative",
            subtitle: "This is an informative feedback",
            feedbackType: .informative
        )
        
        let feedbackView = FeedbackView(
            viewModel: feedbackViewModel,
            style: FeedbackStyles.informativeFeedback
        )
        
        // Feedback - success
        let successViewModel = FeedbackViewModel(
            title: "Success",
            subtitle: "This is an success feedback",
            feedbackType: .success
        )
        
        let successFeedbackView = FeedbackView(
            viewModel: successViewModel,
            style: FeedbackStyles.successFeedback
        )
        
        // Feedback - warning
        let warningFeedbackViewModel = FeedbackViewModel(
            title: "Warning",
            subtitle: "This is an warning feedback",
            feedbackType: .warning
        )
        
        let warningView = FeedbackView(
            viewModel: warningFeedbackViewModel,
            style: FeedbackStyles.warningFeedback
        )
        
        // Feedback - error
        let errorViewModel = FeedbackViewModel(
            title: "Error",
            subtitle: "This is an error feedback",
            feedbackType: .error
        )
        
        let errorView = FeedbackView(
            viewModel: errorViewModel,
            style: FeedbackStyles.errorFeedback
        )
        
        [
            dateInputView,
            currencyInputView,
            segmentedInputView,
            pickerInputView,
            switchInputView,
            primaryButton,
            secondaryButton,
            destructiveButton,
            feedbackView,
            successFeedbackView,
            warningView,
            errorView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview($0)
        }
    }
}


#Preview("SampleViewController") {
    
    let viewController = SampleViewController(
        viewModel: SampleViewModel()
    )
    
    return viewController
}


