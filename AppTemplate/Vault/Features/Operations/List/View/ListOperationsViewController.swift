//
//  ListOperationsViewController.swift
//  Vault
//
//  Created by Miguel Solans on 30/03/2026.
//

import UIKit

class ListOperationsViewController: VaultBaseViewController {
    
    // MARK: - Dependencies
    
    private(set) var viewModel: ListOperationsViewModel
    
    init(viewModel: ListOperationsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }();
    
    lazy var monthSelectorView: MonthSelectorView = {
        let view = MonthSelectorView(viewModel: viewModel.monthSelectorViewModel)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view;
    }();
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizationTableName = "ListOperations";
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
    }
}

// MARK: - UI Setup

extension ListOperationsViewController {
    func setupMonthSelector() {
        view.addSubview(monthSelectorView)
        
        NSLayoutConstraint.activate([
            monthSelectorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            monthSelectorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            monthSelectorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            monthSelectorView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        monthSelectorView.isHidden = !viewModel.canFilter
    }
    
    func setupTableView() {
        
        view.addSubview(self.tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: monthSelectorView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
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
    
    func setupBarButtonItems() {
        
        guard viewModel.canAddOperation else { return }
        
        var childMenus: [UIMenu] = []
        
        let addExpenseAction = UIAction(title: "Expense", image: UIImage(systemName: "arrow.up"), handler: { _ in
            self.didTapAddExpense()
        })
        
        let addIncomeAction = UIAction(title: "Income", image: UIImage(systemName: "arrow.down"), handler: { _ in
            self.didTapAddIncome()
        })
        
        childMenus.append(
            .init(title: "", options: .displayInline, children: [addExpenseAction, addIncomeAction])
        )
        
        if viewModel.isAddFromCameraAvailable {
            let fromCameraAction = UIAction(title: "From camera", image: UIImage(systemName: "camera"), handler: { _ in
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
    
    func setupContentUnavailable() {
        setNeedsUpdateContentUnavailableConfiguration()
    }
    
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        
        var emptyView: UIContentUnavailableView?
        
        if viewModel.numberOfSections == 0 {
            
            var config = UIContentUnavailableConfiguration.empty()
            
            config.background.backgroundColor = .systemBackground
            config.image = UIImage(systemName: "list.bullet")
            config.text = "No Operations"
            config.secondaryText = "You can add operations in the plus button"
            
            emptyView = UIContentUnavailableView(configuration: config)
            
            
        }
        
        tableView.backgroundView = emptyView
    }
}

// MARK: - Actions
extension ListOperationsViewController {
    @objc func didTapAddOperation() {
        viewModel.didTapAddOperation()
    }
    
    @objc func didTapAddIncome() {
        viewModel.didTapAddOperation(of: .income)
    }
    
    @objc func didTapAddExpense() {
        viewModel.didTapAddOperation(of: .expense)
    }
    
    @objc func didTapAddFromCamera() {
        viewModel.didTapAddFromCamera()
    }
}

// MARK: - UITableView delegates
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
            title: localized("list_operations_delete")
        ) { [weak self] in
            self?.viewModel.didTapDeleteOperation(at: indexPath)
        }
        
        let editAction = UIContextualAction(style: .normal, title: localized("list_operations_edit")) { [weak self] _, _, completion in
            self?.viewModel.didTapEditOperation(at: indexPath)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        return configuration
    }
}
