//
//  CategoryDetailViewController.swift
//  Vault
//
//  Created by Miguel Solans on 10/05/2026.
//

import UIKit
import CoreKit

final class CategoryDetailViewController: VaultBaseViewController {
    
    private static let detailCellIdentifier = "OperationDetailCell"
    
    private(set) var viewModel: CategoryDetailViewModel
    
    init(viewModel: CategoryDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.backgroundColor = .clear
        tableView.alwaysBounceVertical = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    private lazy var headerView: OperationDetailHeaderView = {
        let view = OperationDetailHeaderView()
        
        view.configure(with: viewModel.headerViewModel)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderViewHeight()
    }
    
    override func setupUI() {
        view.backgroundColor = UIColor(resource: .background)
        setupNavigationItems()
        setupTableView()
        setupConstraints()
    }
    
    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            
            self.updateUI()
        }
        
        viewModel.onSuccess = { [weak self] in
            guard let self = self else { return }
            
            self.notifyFeedback(.success)
        }
        
        viewModel.onError = { [weak self] message in
            guard let self = self else { return }
            
            self.presentAlert(with: "Error", and: message)
            self.notifyFeedback(.error)
        }
    }
    
    private func updateUI() {
        self.title = self.viewModel.title
        self.navigationItem.subtitle = self.viewModel.subtitle
        self.tableView.reloadData()
    }
}

extension CategoryDetailViewController {
    
    private func setupNavigationItems() {
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
        
        var actions: [UIAction] = []
        
        if viewModel.canEdit {
            let action = UIAction(title: "Edit", image: UIImage(systemName: "pencil"), handler: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.didTapEdit()
            })
            
            actions.append(action)
        }
        
        if viewModel.canDelete {
            let action = makeConfirmedMenuAction(
                title: "Delete",
                image: UIImage(systemName: "trash")
            ) { [weak self] in
                guard let self = self else { return }
                self.viewModel.didTapDelete()
            }
            
            actions.append(action)
        }
        
        let menu = UIMenu(
            title: "",
            options: .displayInline,
            children: actions
        )
        
        let moreBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            menu: menu
        )
        
        navigationItem.rightBarButtonItem = moreBarButtonItem
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = headerView
        
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.detailCellIdentifier
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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

// MARK: - UITableView Delegates & DataSource -
extension CategoryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.detailCellIdentifier,
            for: indexPath
        )
        
        let row = viewModel.row(at: indexPath)
        
        var content = UIListContentConfiguration.valueCell()
        content.text = row.title
        content.secondaryText = row.value
        
        if let systemImageName = row.systemImageName {
            content.image = UIImage(systemName: systemImageName)?
                .withTintColor(.black)
        }
        
        content.textProperties.font = AppFonts.rowTitle
        content.secondaryTextProperties.font = AppFonts.rowAmount
        content.secondaryTextProperties.color = .secondaryLabel
        
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - Actions -
extension CategoryDetailViewController {
    
}
