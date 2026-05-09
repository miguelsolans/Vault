//
//  SettingsViewController.swift
//  Vault
//
//  Created by Miguel Solans on 02/04/2026.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var viewModel: SettingsViewModel
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }();

    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = NSLocalizedString("settings_title", tableName: "Settings", comment: "")
        
        setupTableView()
    }
    
    func setupTableView() {
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.estimatedRowHeight = 60 // or 70–80 depending on your design
        
        tableView.register(
            MenuOptionTableViewCell.self,
            forCellReuseIdentifier: MenuOptionTableViewCell.identifier
        )
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

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
                self.viewModel.deleteData()
            }
            return
        }
        
        viewModel.didSelectRowAtIndex(at: indexPath)
    }
    
}
