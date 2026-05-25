//
//  SettingsViewController.swift
//  Vault
//
//  Created by Miguel Solans on 02/04/2026.
//

import UIKit
import CoreKit

final class SettingsViewController: VaultBaseViewController {
    
    // MARK: - Dependencies
    private(set) var viewModel: SettingsViewModel
    
    init(viewModel: SettingsViewModel) {
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
    }
    
    override func setupUI() {
        title = NSLocalizedString("settings_title", tableName: "Settings", comment: "")
        view.backgroundColor = UIColor(resource: .background)
        setupTableView()
        setupConstraints()
    }
    
    override func setupBindings() {
        viewModel.onSuccess = { [weak self] _ in
            guard let self else { return }
            
            self.notifyFeedback(.success)
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

extension SettingsViewController {
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.estimatedRowHeight = 60
        
        tableView.register(
            MenuOptionTableViewCell.self,
            forCellReuseIdentifier: MenuOptionTableViewCell.identifier
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

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MenuOptionTableViewCell.identifier,
            for: indexPath
        ) as! MenuOptionTableViewCell
        
        let vm = viewModel.cellViewModel(at: indexPath)
        cell.configure(with: vm)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        
        guard cellViewModel.option != .deleteAllData else {
            presentConfirmation(
                .delete(
                    title: NSLocalizedString("settings_delete_information", tableName: "Settings", comment: ""),
                    message: NSLocalizedString("settings_delete_information_message", tableName: "Settings", comment: ""),
                    confirmTitle: NSLocalizedString("settings_delete_action", tableName: "Settings", comment: ""),
                    cancelTitle: NSLocalizedString("settings_delete_cancel", tableName: "Settings", comment: "")
                )
            ) { [weak self] in
                guard let self = self else { return }
                self.viewModel.didTapDeleteAllData()
            }
            return
        }
        
        viewModel.didSelectRowAtIndex(at: indexPath)
    }
    
}
