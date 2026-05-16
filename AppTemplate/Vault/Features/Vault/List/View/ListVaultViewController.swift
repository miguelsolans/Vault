//
//  ListVaultViewController.swift
//  Vault
//
//  Created by Miguel Solans on 08/04/2026.
//

import UIKit

final class ListVaultViewController: UIViewController {
    
    private(set) var viewModel: ListVaultViewModel
    
    init(viewModel: ListVaultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
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
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = viewModel.screenTitle
        navigationItem.subtitle = viewModel.screenSubtitle
        
        setupTableView()
        setupBarButtonItems()
        setupBindings()
    }
    
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
        tableView.register(VaultTableViewCell.self, forCellReuseIdentifier: VaultTableViewCell.identifier)
        
        tableView.separatorStyle = .none
    }
    
    func setupBarButtonItems() {
        
        guard viewModel.canManageVaults else { return }
        
        let addOperationButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapCreateVault)
        )
        
        navigationItem.rightBarButtonItem = addOperationButtonItem
    }
    
    @objc private func didTapCreateVault() {
        viewModel.didTapCreateVault()
    }
    
    func presentExportFileDialog(csvContent: String, suggestedFilename: String) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(suggestedFilename)

        try? FileManager.default.removeItem(at: tempURL)

        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
        } catch {
            let alert = UIAlertController(title: "Export Error", message: "Unable to prepare CSV file for export.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let documentPicker = UIDocumentPickerViewController(forExporting: [tempURL], asCopy: true)
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true)
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard viewModel.canManageVaults else { return nil }
        
        let vault = viewModel.cellViewModel(at: indexPath)
        
        var actions: [UIContextualAction] = []
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            guard let self = self else { return }
            
            self.viewModel.editVault(at: indexPath)
            
            completion(true)
        }
        
        editAction.backgroundColor = .systemBlue
        
        actions.append(editAction)
        
        if !vault.isFavorite {
            let deleteAction = makeConfirmedContextualAction(title: "Delete") { [weak self] in
                self?.viewModel.deleteVault(at: indexPath)
            }
            
            actions.append(deleteAction)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard viewModel.canManageVaults else { return nil }
        
        let vault = viewModel.cellViewModel(at: indexPath)
        
        var actions: [UIContextualAction] = []
        
        if !vault.isFavorite {
            let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { [weak self] _, _, completion in
                guard let self = self else { return }
                
                self.viewModel.favoriteVault(at: indexPath)
                
                completion(true)
            }
            
            favoriteAction.backgroundColor = .systemOrange
            
            actions.append(favoriteAction)
        }
        
        let exportAction = UIContextualAction(style: .normal, title: "Export") { [weak self] _, _, completion in
            guard let self = self else { return }
            
            self.viewModel.exportVault(at: indexPath)
            
            completion(true)
        }
        
        actions.append(exportAction)
        
        let configuration = UISwipeActionsConfiguration(actions: actions)
        
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
}

extension ListVaultViewController {
    fileprivate func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            
            self.tableView.reloadData()
        }
    }
}
