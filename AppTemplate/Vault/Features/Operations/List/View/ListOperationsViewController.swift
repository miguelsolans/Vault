//
//  ListOperationsViewController.swift
//  Vault
//
//  Created by Miguel Solans on 30/03/2026.
//

import UIKit

final class ListOperationsViewController: VaultBaseViewController {
    
    // MARK: - Dependencies
    
    private(set) var viewModel: ListOperationsViewModel
    
    init(
        viewModel: ListOperationsViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        
        view.axis = .vertical
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var monthSelectorView: MonthSelectorView = {
        let view = MonthSelectorView(viewModel: viewModel.monthSelectorViewModel)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view;
    }();
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getData()
    }
    
    override func setupUI() {
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
        view.backgroundColor = UIColor(resource: .background)
        setupStackView()
        setupMonthSelector()
        setupTableView()
        setupBarButtonItems()
    }
    
    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            
            self.setupContentUnavailable()
            
            self.tableView.reloadData()
        }
        
        viewModel.onError = { [weak self] message in
            guard let self = self else { return }
            
            self.presentAlert(with: L10n.Common.error, and: message);
        }
    }
}

// MARK: - UI Setup

extension ListOperationsViewController {
    
    private func setupStackView() {
        stackView.addArrangedSubview(monthSelectorView)
        stackView.addArrangedSubview(tableView)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupMonthSelector() {
        
        NSLayoutConstraint.activate([
            monthSelectorView.heightAnchor.constraint(equalToConstant: 46)
        ])
        
        monthSelectorView.isHidden = !viewModel.canFilter
    }
    
    private func setupTableView() {
        
        tableView.delegate = self;
        tableView.dataSource = self
        
        tableView.register(
            OperationTableViewCell.self,
            forCellReuseIdentifier: OperationTableViewCell.identifier
        )
        
        tableView.register(
            OperationSectionHeaderView.self,
            forHeaderFooterViewReuseIdentifier: OperationSectionHeaderView.identifier
        )
    }
    
    private func setupBarButtonItems() {
        
        guard viewModel.canAddOperation else { return }
        
        var childMenus: [UIMenu] = []
        
        let addExpenseAction = UIAction(title: L10n.Common.expense, image: UIImage(systemName: "arrow.up"), handler: { _ in
            self.didTapAddExpense()
        })
        
        let addIncomeAction = UIAction(title: L10n.Common.income, image: UIImage(systemName: "arrow.down"), handler: { _ in
            self.didTapAddIncome()
        })
        
        childMenus.append(
            .init(title: "", options: .displayInline, children: [addExpenseAction, addIncomeAction])
        )
        
        if viewModel.isAddFromCameraAvailable {
            let fromCameraAction = UIAction(title: L10n.Operations.fromCamera, image: UIImage(systemName: "camera"), handler: { _ in
                self.didTapAddFromCamera()
            })
            
            childMenus.append(
                .init(title: "", options: .displayInline, children: [fromCameraAction])
            )
        }
        
        let menu = UIMenu(title: "", children: childMenus)
        
        let addOperationAction = UIAction(title: "", image: UIImage(systemName: "plus"), handler: { _ in
            self.didTapAddOperation()
        });
        
        let addBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: addOperationAction, menu: menu)
        
        navigationItem.rightBarButtonItem = addBarButtonItem
    }
    
    private func setupContentUnavailable() {
        setNeedsUpdateContentUnavailableConfiguration()
    }
    
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        updateEmptyContentBackground(
            for: tableView,
            configuration: viewModel.numberOfSections == 0 ? noOperationsEmptyContentConfiguration() : nil
        )
    }
    
    private func noOperationsEmptyContentConfiguration() -> EmptyContentConfiguration {
        EmptyContentConfiguration(
            image: UIImage(systemName: "list.bullet"),
            title: L10n.Operations.emptyTitle,
            message: L10n.Operations.emptyMessage
        )
    }
}

// MARK: - UITableView delegates -

extension ListOperationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows(at: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: OperationSectionHeaderView.identifier
        ) as! OperationSectionHeaderView
        
        let vm = viewModel.headerViewModel(at: section)
        header.configure(with: vm)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let vm = viewModel.cellViewModel(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: OperationTableViewCell.identifier,
            for: indexPath
        ) as! OperationTableViewCell
        
        cell.configure(with: vm)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectOperation(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = makeConfirmedContextualAction(
            title: L10n.Common.delete
        ) { [weak self] in
            self?.viewModel.didTapDeleteOperation(at: indexPath)
        }
        
        let editAction = UIContextualAction(style: .normal, title: L10n.Common.edit) { [weak self] _, _, completion in
            self?.viewModel.didTapEditOperation(at: indexPath)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let deleteAction = makeConfirmedMenuAction(
            title: L10n.Common.delete,
            image: UIImage(systemName: "trash")
        ) { [weak self] in
            guard let self = self else { return }
            self.viewModel.didTapDeleteOperation(at: indexPath)
        }
        
        let editAction = UIAction(title: L10n.Common.edit, image: UIImage(systemName: "pencil")) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.didTapEditOperation(at: indexPath)
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}

// MARK: - Actions -

extension ListOperationsViewController {
    @objc private func didTapAddOperation() {
        viewModel.didTapAddOperation()
    }
    
    @objc private func didTapAddIncome() {
        viewModel.didTapAddOperation(of: .income)
    }
    
    @objc private func didTapAddExpense() {
        viewModel.didTapAddOperation(of: .expense)
    }
    
    @objc private func didTapAddFromCamera() {
        viewModel.didTapAddFromCamera()
    }
}
