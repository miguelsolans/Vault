//
//  AddOperationViewController.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import UIKit
import AppUIKit
import CoreKit

final class AddOperationViewController: BaseViewController {
    
    private(set) var viewModel: AddOperationViewModel
    
    init(viewModel: AddOperationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    
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
    
    // MARK: - Operation fields
    
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
    
    
    // MARK: - Reimbursement fields
    
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

    private var reimbursementTableViewHeightConstraint: NSLayoutConstraint?

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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        setupScrollView()
        setupStackView()
        setupReimbursementTableView()
        setupConstraints()
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        addReimbursementButton.addTarget(self, action: #selector(addReimbursementTapped), for: .touchUpInside)
        
        refreshReimbursementViews()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
    }
    
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
            TransferMoneyTableViewCell.self,
            forCellReuseIdentifier: TransferMoneyTableViewCell.identifier
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
    
    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            
            self.refreshReimbursementViews()
        }
    }
    
}

extension AddOperationViewController {
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

extension AddOperationViewController {
    @objc private func saveTapped() {
        viewModel.didTapSave()
        
        triggerFeedback(
            .notification(.success)
        )
    }
    
    @objc private func addReimbursementTapped() {
        viewModel.didTapAddReimbursement()
    }
    
}

extension AddOperationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfReimbursements
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TransferMoneyTableViewCell.identifier,
            for: indexPath
        ) as! TransferMoneyTableViewCell

        cell.configure(with: viewModel.reimbursementTableViewModel(at: indexPath))
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
