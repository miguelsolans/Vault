//
//  ListCategoriesViewController.swift
//  Vault
//
//  Created by Miguel Solans on 01/04/2026.
//

import UIKit
import AppUIKit
import CoreKit

final class ListCategoriesViewController: BaseViewController {
    
    private(set) var viewModel: ListCategoriesViewModel
    
    init(viewModel: ListCategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
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
        view.backgroundColor = .systemBackground
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
        
        setupTableView()
        setupBarButtonItems()
        setupConstraints()
    }
    
    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            DispatchQueue.main.async {
                
                guard let self = self else { return }
                
                self.setupContentUnavailable()
                
                self.tableView.reloadData()
                
            }
        }
        
        viewModel.onErrorAlert = { [weak self] message in
            guard let self = self else { return }
            
            self.presentAlert(with: "Error", and: message)
        }
    }
}

// MARK: - UI Setup -
extension ListCategoriesViewController {
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            CategoryTableViewCell.self,
            forCellReuseIdentifier: CategoryTableViewCell.identifier
        )
    }
    
    private func setupBarButtonItems() {
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddCategory)
        )
        
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupContentUnavailable() {
        setNeedsUpdateContentUnavailableConfiguration()
    }
    
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        var config: UIContentUnavailableConfiguration?
        if viewModel.numberOfRows == 0 {
            var empty = UIContentUnavailableConfiguration.empty()
            empty.background.backgroundColor = .systemBackground
            empty.image = UIImage(systemName: "tag")
            empty.text = "No Categories"
            empty.secondaryText = "You can add categories in the plus button"
            config = empty
        }
        contentUnavailableConfiguration = config
    }
}

// MARK: - Actions -
extension ListCategoriesViewController {
    @objc private func didTapAddCategory() {
        viewModel.didTapAddCategory()
    }
}

// MARK: - UITableView Delegates & DataSource -
extension ListCategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.identifier,
            for: indexPath) as! CategoryTableViewCell
        
        let vm = viewModel.category(at: indexPath)
        
        cell.configure(with: vm)
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didTapCategory(at: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        var actions: [UIContextualAction] = []
        
        let category = viewModel.category(at: indexPath)
        
        if category.canDelete {
            let deleteAction = makeConfirmedContextualAction(
                title: NSLocalizedString("list_categories_delete", tableName: "ListCategories", comment: "")
            ) { [weak self] in
                self?.viewModel.deleteCategory(at: indexPath)
            }
            
            actions.append(deleteAction)
        }
        
        
        let editAction = UIContextualAction(style: .normal, title: NSLocalizedString("list_categories_edit", tableName: "ListCategories", comment: "")) { [weak self] _, _, completion in
            self?.viewModel.editCategory(at: indexPath)
            completion(true)
        }
        
        editAction.backgroundColor = .systemBlue
        
        actions.append(editAction)
        
        return UISwipeActionsConfiguration(actions: actions)
    }
}

// MARK: - Alert -
extension ListCategoriesViewController {
    private func presentAlert(with title: String, and message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(okAction);
        
        present(alert, animated: true)
    }
}
