//
//  AddCategoryViewController.swift
//  Vault
//
//  Created by Miguel Solans on 01/04/2026.
//

import UIKit
import AppUIKit
import CoreKit

class AddCategoryViewController: BaseViewController {

    var viewModel: AddCategoryViewModel
    
    init(viewModel: AddCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

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
    
    private lazy var budgetSwitchInputView: SwitchInputView = {
        let view = SwitchInputView(
            viewModel: viewModel.budgetSwitchInputViewModel,
            style: InputStyles.switchStyle
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var budgetInputView: TextFieldInputView = {
        let view = TextFieldInputView(
            viewModel: viewModel.budgetInputViewModel,
            style: InputStyles.textFieldStyle)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("add_category_save", tableName: "AddCategory", comment: ""), for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupUI()
    }

    override func setupUI() {
        title = viewModel.screenTitle
        navigationItem.subtitle = viewModel.subtitle;
        view.backgroundColor = .systemBackground

        setupScrollView()
        setupStackView()
        setupConstraints()

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        budgetInputView.isHidden = !viewModel.isBudgetOn
        colorInputView.isHidden = !viewModel.isShowInDashboardOn
        
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
        
        stackView.addArrangedSubview(operationTypeInputView)
        stackView.addArrangedSubview(emojiInputView)
        stackView.addArrangedSubview(categoryNameInputView)
        stackView.addArrangedSubview(plotSwitchInputView)
        stackView.addArrangedSubview(colorInputView)
        stackView.addArrangedSubview(budgetSwitchInputView)
        stackView.addArrangedSubview(budgetInputView)
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

    
    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            
            self.budgetSwitchInputView.isHidden = !viewModel.isBudgetSectionVisible
            
            self.colorInputView.isHidden = !viewModel.isShowInDashboardOn
            
            self.budgetInputView.isHidden = !viewModel.isBudgetOn
        }
    }
    
}

// MARK: - Actions

extension AddCategoryViewController {
    @objc private func saveTapped() {
        viewModel.didTapSave()
    }
}
