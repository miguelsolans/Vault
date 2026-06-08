//
//  SecurityViewController.swift
//  Vault
//
//  Created by Miguel Solans on 03/04/2026.
//

import UIKit

final class SecurityViewController: VaultBaseViewController {
    
    private(set) var viewModel: SecurityViewModel
    
    init(viewModel: SecurityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRectZero, style: .plain)
        
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }();
    
    // MARK: - Lifecycles
    
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
        setupTableView()
        setupConstraints()
    }
    
    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self else { return }
            
            self.tableView.reloadData()
        }
    }
}

// MARK: - Setup UI

extension SecurityViewController {
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.register(
            SecurityOptionTableViewCell.self,
            forCellReuseIdentifier: SecurityOptionTableViewCell.identifier
        )
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableView delegates

extension SecurityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(at: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.textForHeader(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SecurityOptionTableViewCell.identifier,
            for: indexPath
        ) as! SecurityOptionTableViewCell
        
        let vm = viewModel.cellViewModel(at: indexPath)
        
        cell.configure(with: vm)
        
        cell.onToggleChanged = { [weak self] value in
            guard let self = self else { return }
            
            presentPinConfirmation(from: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModel.didSelectRow(at: indexPath)
    }
}

extension SecurityViewController {
    private func presentPinConfirmation(from indexPath: IndexPath) {
        
        let confirmationDialog = ConfirmationDialog(
            title: L10n.Security.disablePin,
            message: L10n.Security.disablePinMessage,
            confirmTitle: L10n.Common.disable,
            cancelTitle: "Cancel",
            confirmStyle: .destructive
        )
        
        presentConfirmation(confirmationDialog) { [weak self] in
            guard let self else { return }
            
            self.viewModel.toggleChanged(to: false, from: indexPath)
        } onCancel: { [weak self] in
            guard let self else { return }
            
            self.viewModel.getData()
        }
    }
}
