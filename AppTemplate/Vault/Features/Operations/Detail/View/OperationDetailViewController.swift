//
//  OperationDetailViewController.swift
//  Vault
//
//  Created by Miguel Solans on 29/04/2026.
//

import UIKit
import CoreKit

final class OperationDetailViewController: VaultBaseViewController {
    
    private static let detailCellIdentifier = "OperationDetailCell"
    
    private(set) var viewModel: OperationDetailViewModel

    init(viewModel: OperationDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private lazy var headerView: OperationDetailHeaderView = {
        let view = OperationDetailHeaderView()
        
        view.configure(with: viewModel.headerViewModel)
        
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationItems()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderViewHeight()
    }

    override func setupUI() {
        view.backgroundColor = tableView.backgroundColor
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
        
        setupTableView()
        setupConstraints()

    }
    
    private func updateUI() {
        tableView.reloadData()
        headerView.configure(with: viewModel.headerViewModel)
    }
    
    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self else { return }
            
            self.updateUI()
        }
        
        viewModel.onSuccess = { [weak self] feedback in
            guard let self = self else { return }
            
            switch feedback {
            case .showAlert(let message):
                self.presentAlert(with:"Success", and: message)

            case .silent:
                break
            }
            
            self.notifyFeedback(.error)
        }
        
        viewModel.onError = { [weak self] feedback in
            guard let self = self else { return }
            
            switch feedback {
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

extension OperationDetailViewController {
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.alwaysBounceVertical = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = headerView
        
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.detailCellIdentifier
        )
        
        tableView.register(
            ReimbursementTableViewCell.self,
            forCellReuseIdentifier: ReimbursementTableViewCell.identifier
        )
    }
    
    private func setupNavigationItems() {
        
        guard viewModel.isActionAvailable else {
            return
        }
        
        var actions: [UIAction] = []
        
        if viewModel.canEditOperation {
            let action = UIAction(title: "Edit", image: UIImage(systemName: "pencil"), handler: { _ in
                self.viewModel.didTapEdit()
            })
            
            actions.append(action)
        }
        
        if viewModel.canDeleteOperation {
            let action = makeConfirmedMenuAction(
                title: "Delete",
                image: UIImage(systemName: "trash")
            ) { [weak self] in
                self?.viewModel.didTapDelete()
            }
            
            actions.append(action)
        }
        
        let menu = UIMenu(title: "", options: .displayInline, children: actions)
        
        let moreBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            menu: menu
        )
        
        navigationItem.rightBarButtonItem = moreBarButtonItem
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension OperationDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows(at: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.title(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.section(at: indexPath.section) {
        case .operationDetail(let rows):
            let row = rows[indexPath.row]
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Self.detailCellIdentifier,
                for: indexPath
            )
            
            configureValueCell(cell, with: row)
            return cell

        case .reimbursements(let rows):
            let row = rows[indexPath.row]
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ReimbursementTableViewCell.identifier,
                for: indexPath
            ) as! ReimbursementTableViewCell
            
            cell.configure(with: row.tableViewModel)
            return cell

        case .summary(let rows):
            let row = rows[indexPath.row]
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Self.detailCellIdentifier,
                for: indexPath
            )
            
            configureValueCell(cell, with: row)
            return cell
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        guard case .reimbursements = viewModel.section(at: indexPath.section) else {
            return nil
        }

        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            self?.viewModel.didTapEditReimbursement(at: indexPath)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard case .reimbursements = viewModel.section(at: indexPath.section) else {
            return nil
        }
        
        var menu: [UIMenuElement] = []
        
        if viewModel.isReimbursementStatusAvailable(.received, for: indexPath) {
            
            let action = UIAction(title: "Received") { [weak self] _ in
                guard let self else { return }
                self.viewModel.didTapReceivedReimbursementStatus(at: indexPath)
            }
        
            menu.append(action)
        }
        
        if viewModel.isReimbursementStatusAvailable(.expected, for: indexPath) {
            let action = UIAction(title: "Expected") { [weak self] _ in
                guard let self else { return }
                self.viewModel.didTapExpectedReimbursementStatus(at: indexPath)
            }
        
            menu.append(action)
        }
        
        if viewModel.isReimbursementStatusAvailable(.cancelled, for: indexPath) {
            let action = UIAction(title: "Cancelled") { [weak self] _ in
                guard let self else { return }
                self.viewModel.didTapCancelledReimbursementStatus(at: indexPath)
            }
        
            menu.append(action)
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", children: menu)
        }
        
    }
    
    private func configureValueCell(_ cell: UITableViewCell, with row: SimpleDetailInfoRow) {
        var content = UIListContentConfiguration.valueCell()
        content.text = row.title
        content.secondaryText = row.value
        
        if let systemImageName = row.systemImageName {
            content.image = UIImage(systemName: systemImageName)?.withTintColor(.black)
        }
        
        content.textProperties.font = AppFonts.rowTitle
        content.secondaryTextProperties.font = AppFonts.rowAmount
        content.secondaryTextProperties.color = .secondaryLabel
        
        cell.contentConfiguration = content
        cell.selectionStyle = .none
    }
    
    private func updateTableHeaderViewHeight() {
        guard let tableHeaderView = tableView.tableHeaderView else {
            return
        }

        let targetSize = CGSize(
            width: tableView.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )

        let height = tableHeaderView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        guard tableHeaderView.frame.width != targetSize.width
                || tableHeaderView.frame.height != height else {
            return
        }

        tableHeaderView.frame.size = CGSize(width: targetSize.width, height: height)
        tableView.tableHeaderView = tableHeaderView
    }
}
