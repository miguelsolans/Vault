//
//  OperationFormViewController.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import UIKit
import AppUIKit
import CoreKit

final class OperationFormViewController: VaultBaseViewController {
    
    private(set) var viewModel: OperationFormViewModel
    
    init(viewModel: OperationFormViewModel) {
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
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var operationStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var reimbursementStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var ocrFeedbackView: FeedbackView = {
        let view = FeedbackView(viewModel: viewModel.ocrFeedback, style: FeedbackStyles.informativeFeedback)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var operationTypeInputView: SegmentedInputView = {
        let view = SegmentedInputView(viewModel: viewModel.operationTypeInputViewModel, style: InputStyles.segmentedStyle)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var categoryInputView: OptionPickerInputView = {
        let view = OptionPickerInputView(viewModel: viewModel.categoryInputViewModel, style: InputStyles.pickerStyle)
        
        return view
    }()
    
    private lazy var amountInputView: TextFieldInputView = {
        let view = TextFieldInputView(viewModel: viewModel.amountInputViewModel, style: InputStyles.textFieldStyle)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var titleInputView: TextFieldInputView = {
        let view = TextFieldInputView(viewModel: viewModel.titleInputViewModel, style: InputStyles.textFieldStyle)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }();
    
    private lazy var dateInputView: DatePickerInputView = {
        let view = DatePickerInputView(viewModel: viewModel.dateInputViewModel, style: InputStyles.datePickerStyle)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var reimbursementSwitchView: SwitchInputView = {
        let view = SwitchInputView(viewModel: viewModel.reimbursementViewModel, style: InputStyles.switchStyle)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view;
    }()
    
    private lazy var reimbursementTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 76
        tableView.tableFooterView = UIView()

        return tableView
    }()
    
    private lazy var addReimbursementButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.apply(style: ButtonStyles.secondary, title: "Add reimbursement")
        
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.apply(
            style: ButtonStyles.primary,
            title: "Save"
        )
        
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var reimbursementTableViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupUI()
        setupGestures()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateReimbursementTableViewHeight()
    }

    // MARK: - Setup
    
    override func setupUI() {
        view.backgroundColor = .systemBackground
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
        
        view.addSubview(scrollView)
        
        setupStackView()
        setupReimbursementTableView()
        setupConstraints()
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        addReimbursementButton.addTarget(self, action: #selector(addReimbursementTapped), for: .touchUpInside)
        
        refreshReimbursementViews()
    }
    
    override func setupBindings() {
        setupEventBindings()
        setupOperationTypeBindings()
        setupCategoryBindings()
        setupDateBindings()
        setupAmountBindings()
        setupTitleBindings()
        setupReimbursementBindings()
    }
}

// MARK: UI Setup
extension OperationFormViewController {
    
    private func setupStackView() {
        
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(ocrFeedbackView)
        ocrFeedbackView.isHidden = viewModel.isOcrFeedbackHidden
        
        operationStackView.addArrangedSubview(operationTypeInputView)
        operationStackView.addArrangedSubview(categoryInputView)
        operationStackView.addArrangedSubview(amountInputView)
        operationStackView.addArrangedSubview(titleInputView)
        operationStackView.addArrangedSubview(dateInputView)
        
        reimbursementStackView.addArrangedSubview(reimbursementSwitchView)
        reimbursementStackView.addArrangedSubview(reimbursementTableView)
        reimbursementStackView.addArrangedSubview(addReimbursementButton)
        
        stackView.addArrangedSubview(operationStackView)
        stackView.addArrangedSubview(reimbursementStackView)
        stackView.addArrangedSubview(saveButton)
    }
    
    private func setupReimbursementTableView() {
        reimbursementTableView.dataSource = self
        reimbursementTableView.delegate = self

        reimbursementTableView.register(
            ReimbursementTableViewCell.self,
            forCellReuseIdentifier: ReimbursementTableViewCell.identifier
        )

        reimbursementTableViewHeightConstraint = reimbursementTableView.heightAnchor.constraint(equalToConstant: 0)
        reimbursementTableViewHeightConstraint?.isActive = true
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
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap))
        
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
}

extension OperationFormViewController {
    private func refreshReimbursementViews() {
        reimbursementStackView.isHidden = viewModel.isReimbursementHidden
        reimbursementTableView.isHidden = !viewModel.isReimbursementOn
        addReimbursementButton.isHidden = viewModel.isAddReimbursementHidden

        reimbursementTableView.reloadData()
        updateReimbursementTableViewHeight()
    }

    private func updateReimbursementTableViewHeight() {
        guard viewModel.numberOfReimbursements > 0 else {
            reimbursementTableViewHeightConstraint?.constant = 0
            return
        }

        reimbursementTableView.layoutIfNeeded()
        let estimatedHeight = CGFloat(viewModel.numberOfReimbursements) * reimbursementTableView.estimatedRowHeight
        reimbursementTableViewHeightConstraint?.constant = max(
            reimbursementTableView.contentSize.height,
            estimatedHeight
        )
    }
}

// MARK: - Actions

extension OperationFormViewController {
    @objc private func saveTapped() {
        endEditingAndDismissExpandedInputs()
        viewModel.didTapSave()
    }
    
    @objc private func addReimbursementTapped() {
        endEditingAndDismissExpandedInputs()
        viewModel.didTapAddReimbursement()
    }
    
    @objc private func handleOutsideTap() {
        endEditingAndDismissExpandedInputs()
    }
    
    private func dismissExpandedInputs() {
        categoryInputView.dismiss()
        dateInputView.dismiss()
    }
    
    private func endEditingAndDismissExpandedInputs() {
        view.endEditing(true)
        dismissExpandedInputs()
    }
}

extension OperationFormViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfReimbursements
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ReimbursementTableViewCell.identifier,
            for: indexPath
        ) as! ReimbursementTableViewCell

        cell.configure(with: viewModel.reimbursementTableViewModel(at: indexPath))
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        endEditingAndDismissExpandedInputs()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var actions: [UIContextualAction] = []
        
        if viewModel.isDeleteReimbursementAvailable(for: indexPath) {
            let action = makeConfirmedContextualAction(title: "Delete") { [weak self] in
                self?.viewModel.didTapDeleteReimbursement(at: indexPath)
            }
            
            actions.append(action)
        }
        
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var actions: [UIContextualAction] = []
        
        if viewModel.isLeadingAvailable(.expected, for: indexPath) {
            let action = UIContextualAction(style: .normal, title: "Expected") { [weak self] _, _, completion in
                self?.viewModel.didTapExpectedReimbursementStatus(at: indexPath)
                completion(true)
            }
            
            action.backgroundColor = .systemYellow
            
            actions.append(action)
        }
        
        
        if viewModel.isLeadingAvailable(.received, for: indexPath) {
            let action = UIContextualAction(style: .normal, title: "Received") { [weak self] _, _, completion in
                self?.viewModel.didTapReceivedReimbursementStatus(at: indexPath)
                completion(true)
            }
            
            action.backgroundColor = .systemGreen
            
            actions.append(action)
        }
        
        if viewModel.isLeadingAvailable(.cancelled, for: indexPath) {
            let action = UIContextualAction(style: .normal, title: "Cancelled") { [weak self] _, _, completion in
                self?.viewModel.didTapCancelledReimbursementStatus(at: indexPath)
                completion(true)
            }
            
            action.backgroundColor = .systemRed
            
            actions.append(action)
        }
        
        return UISwipeActionsConfiguration(actions: actions)
    }
}

// MARK: - Bindings
extension OperationFormViewController {
    
    private func setupEventBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            
            self.refreshReimbursementViews()
        }
        
        viewModel.onSuccess = { [weak self] _ in
            guard let self = self else { return }
            
            self.notifyFeedback(.success)
        }
        
        viewModel.onError = { [weak self] error in
            guard let self = self else { return }
            
            switch error {
            case .showAlert(let message):
                self.presentAlert(with:"Error", and: message)

            case .silent:
                break
            }
            
            self.notifyFeedback(.error)
        }
    }
    
    private func setupOperationTypeBindings() {
        let existingOperationTypeSelectionChanged = viewModel.operationTypeInputViewModel.onSelectionChanged
        viewModel.operationTypeInputViewModel.onSelectionChanged = { [weak self] selectedIndex in
            self?.endEditingAndDismissExpandedInputs()
            existingOperationTypeSelectionChanged?(selectedIndex)
        }
    }
    
    private func setupCategoryBindings() {
        let existingCategoryBeginChoosing = viewModel.categoryInputViewModel.onBeginChoosing
        viewModel.categoryInputViewModel.onBeginChoosing = { [weak self] in
            self?.view.endEditing(true)
            self?.dateInputView.dismiss()
            existingCategoryBeginChoosing?()
        }
    }
    
    private func setupDateBindings() {
        let existingDateBeginChoosing = viewModel.dateInputViewModel.onBeginChoosing
        viewModel.dateInputViewModel.onBeginChoosing = { [weak self] in
            self?.view.endEditing(true)
            self?.categoryInputView.dismiss()
            existingDateBeginChoosing?()
        }
    }
    
    private func setupAmountBindings() {
        let existingAmountBeginEditing = viewModel.amountInputViewModel.onBeginEditing
        viewModel.amountInputViewModel.onBeginEditing = { [weak self] in
            self?.dismissExpandedInputs()
            existingAmountBeginEditing?()
        }
    }
    
    private func setupTitleBindings() {
        let existingTitleBeginEditing = viewModel.titleInputViewModel.onBeginEditing
        viewModel.titleInputViewModel.onBeginEditing = { [weak self] in
            self?.dismissExpandedInputs()
            existingTitleBeginEditing?()
        }
    }
    
    private func setupReimbursementBindings() {
        let existingReimbursementValueChanged = viewModel.reimbursementViewModel.onValueChanged
        viewModel.reimbursementViewModel.onValueChanged = { [weak self] isOn in
            self?.endEditingAndDismissExpandedInputs()
            existingReimbursementValueChanged?(isOn)
        }
    }
}
