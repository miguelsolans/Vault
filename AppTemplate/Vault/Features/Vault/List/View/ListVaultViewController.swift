//
//  ListVaultViewController.swift
//  Vault
//
//  Created by Miguel Solans on 08/04/2026.
//

import UIKit

final class ListVaultViewController: VaultBaseViewController {
    
    // MARK: - Dependencies
    
    private(set) var viewModel: ListVaultViewModel
    
    init(viewModel: ListVaultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getData()
    }
    
    override func setupUI() {
        view.backgroundColor = UIColor(resource: .background)
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
        
        setupTableView()
        setupBarButtonItems()
        setupBindings()
    }
    
    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            
            self.tableView.reloadData()
        }
    }
}

// MARK: - UI Setup

extension ListVaultViewController {
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            VaultTableViewCell.self,
            forCellReuseIdentifier: VaultTableViewCell.identifier
        )
        
        tableView.separatorStyle = .none
    }
    
    func setupBarButtonItems() {
        
        if isModal {
            let closeButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(didTapClose)
            )
            
            navigationItem.rightBarButtonItem = closeButtonItem
        }
        
        guard viewModel.isAddVaultAvailable else { return }
        
        let addOperationButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapCreateVault)
        )
        
        navigationItem.rightBarButtonItem = addOperationButtonItem
    }
}

extension ListVaultViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: VaultTableViewCell.identifier, for: indexPath) as! VaultTableViewCell
        
        let vaultViewModel = viewModel.cellViewModel(at: indexPath)
        
        cell.configure(with: vaultViewModel)
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectVault(at: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        guard viewModel.canManageVaults else { return nil }
        
        let vault = viewModel.cellViewModel(at: indexPath)
        
        var actions: [UIContextualAction] = []
        
        if viewModel.isEditAvailable {
            let editAction = UIContextualAction(style: .normal, title: L10n.Common.edit) { [weak self] _, _, completion in
                guard let self = self else { return }
                
                self.viewModel.editVault(at: indexPath)
                
                completion(true)
            }
            
            editAction.backgroundColor = .systemBlue
            
            actions.append(editAction)
        }
        
        if viewModel.isDeleteAvailable(cell: vault) {
            let deleteAction = makeConfirmedContextualAction(title: L10n.Common.delete) { [weak self] in
                self?.viewModel.deleteVault(at: indexPath)
            }
            
            actions.append(deleteAction)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard viewModel.canManageVaults else { return nil }
        
        let vault = viewModel.cellViewModel(at: indexPath)
        
        var actions: [UIContextualAction] = []
        
        if viewModel.isFavoriteAvailable(cell: vault) {
            let favoriteAction = UIContextualAction(style: .normal, title: L10n.Vaults.favorite) { [weak self] _, _, completion in
                guard let self = self else { return }
                
                self.viewModel.favoriteVault(at: indexPath)
                
                completion(true)
            }
            
            favoriteAction.backgroundColor = .systemOrange
            
            actions.append(favoriteAction)
        }
        
        if viewModel.isExportAvailable {
            let exportAction = UIContextualAction(style: .normal, title: L10n.Vaults.export) { [weak self] _, _, completion in
                guard let self = self else { return }
                
                self.viewModel.exportVault(at: indexPath)
                
                completion(true)
            }
            
            actions.append(exportAction)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        guard viewModel.canManageVaults else { return nil }
        
        let vault = viewModel.cellViewModel(at: indexPath)
        
        var children: [UIMenuElement] = []
        
        if viewModel.isEditAvailable {
            
            let action = UIAction(
                title: L10n.Common.edit,
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.editVault(at: indexPath)
            }
            
            children.append(action)
        }
        
        if viewModel.isFavoriteAvailable(cell: vault) {
            
            let action = UIAction(
                title: L10n.Vaults.favorite,
                image: UIImage(systemName: "star")
            ) { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.favoriteVault(at: indexPath)
            }
            
            children.append(action)
            
        }
        
        if viewModel.isDeleteAvailable(cell: vault) {
            
            let action = makeConfirmedMenuAction(
                title: L10n.Common.delete,
                image: UIImage(systemName: "trash")
            ) { [weak self] in
                guard let self = self else { return }
                self.viewModel.deleteVault(at: indexPath)
            }
            
            children.append(action)
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", children: children)
        }
        
    }
}

// MARK: - Actions

extension ListVaultViewController {
    @objc private func didTapCreateVault() {
        viewModel.didTapCreateVault()
    }
    
    @objc private func didTapClose() {
        viewModel.didTapClose()
    }
}

// MARK: - Dialogs

extension ListVaultViewController {
    public func presentExportFileDialog(csvContent: String, suggestedFilename: String) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(suggestedFilename)

        try? FileManager.default.removeItem(at: tempURL)

        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
        } catch {
            let alert = UIAlertController(
                title: "Export Error",
                message: "Unable to prepare CSV file for export.",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(
                title: "OK",
                style: .default
            )
            
            alert.addAction(okAction)
            
            present(alert, animated: true)
            
            return
        }

        let documentPicker = UIDocumentPickerViewController(
            forExporting: [tempURL],
            asCopy: true
        )
        
        documentPicker.modalPresentationStyle = .formSheet
        
        present(documentPicker, animated: true)
    }
}
