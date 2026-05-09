//
//  OperationDetailViewController.swift
//  Vault
//
//  Created by Miguel Solans on 29/04/2026.
//

import UIKit
import CoreKit

final class OperationDetailViewController: BaseViewController {
    
    private static let detailCellIdentifier = "OperationDetailCell"
    
    private(set) var viewModel: OperationDetailViewModel

    init(viewModel: OperationDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationItems()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderViewHeight()
    }

    override func setupUI() {
        
        view.backgroundColor = tableView.backgroundColor
        
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

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
        
        tableView.alwaysBounceVertical = false
    }
    
    private func setupNavigationItems() {
        title = viewModel.title
        
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
    
    override func setupBindings() {
        // TODO: Bindings if needed.
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var actions: [UIContextualAction] = []
        
        switch viewModel.section(at: indexPath.section) {
        case .operationDetail(let array):
            actions = []
        case .reimbursements(let array):
            let action = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
                guard let self = self else { return }
                
                self.viewModel.didTapEditReimbursement(at: indexPath)
            }
            
            actions.append(action)
        case .summary(let array):
            actions = []
        }
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        
        return configuration
    }
    
    private func configureValueCell(_ cell: UITableViewCell, with row: OperationDetailInfoRow) {
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
}
