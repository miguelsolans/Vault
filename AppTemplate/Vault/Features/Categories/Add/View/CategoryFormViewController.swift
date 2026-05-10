//
//  CategoryFormViewController.swift
//  Vault
//
//  Created by Miguel Solans on 01/04/2026.
//

import UIKit
import AppUIKit
import CoreKit

final class CategoryFormViewController: BaseViewController {

    private(set)var viewModel: CategoryFormViewModel
    
    init(viewModel: CategoryFormViewModel) {
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

    private lazy var categoryNameInputView: TextFieldInputView = {
        let inputView = TextFieldInputView(
            viewModel: viewModel.categoryNameInputViewModel,
            style: InputStyles.textFieldStyle
        )
        
        inputView.translatesAutoresizingMaskIntoConstraints = false
        
        return inputView
    }()
    
    private lazy var emojiInputView: TextFieldInputView = {
        let inputView = TextFieldInputView(
            viewModel: viewModel.emojiInputViewModel,
            style: InputStyles.textFieldStyle
        )
        
        inputView.translatesAutoresizingMaskIntoConstraints = false
        
        return inputView
    }()

    private lazy var operationTypeInputView: SegmentedInputView = {
        let view = SegmentedInputView(
            viewModel: viewModel.operationTypeInputViewModel,
            style: InputStyles.segmentedStyle
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private lazy var colorInputView: ColorPickerInputView = {
        let view = ColorPickerInputView(
            viewModel: viewModel.colorInputViewModel,
            style: InputStyles.colorPickerStyle
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var plotSwitchInputView: SwitchInputView = {
        let view = SwitchInputView(
            viewModel: viewModel.plotSwitchInputViewModel,
            style: InputStyles.switchStyle
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view;
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.apply(
            style: ButtonStyles.primary,
            title: "Save"
        )
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupUI()
    }

    override func setupUI() {
        view.backgroundColor = .systemBackground
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle;

        view.addSubview(scrollView)
        
        setupStackView()
        setupConstraints()

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        colorInputView.isHidden = !viewModel.isShowInDashboardOn
        
    }

    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            self.colorInputView.isHidden = !viewModel.isShowInDashboardOn
        }
        
        viewModel.onSuccess = { [weak self] in
            guard let self = self else { return }
            
            self.notifyFeedback(.success)
        }
        
        viewModel.onError = { [weak self] in
            guard let self = self else { return }
            
            self.notifyFeedback(.error)
        }
    }
    
}

extension CategoryFormViewController {
    
    private func setupStackView() {
        
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(operationTypeInputView)
        stackView.addArrangedSubview(emojiInputView)
        stackView.addArrangedSubview(categoryNameInputView)
        stackView.addArrangedSubview(plotSwitchInputView)
        stackView.addArrangedSubview(colorInputView)
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

extension CategoryFormViewController {
    @objc private func saveTapped() {
        viewModel.didTapSave()
    }
}
