//
//  SecurityViewController.swift
//  Vault
//
//  Created by Miguel Solans on 03/04/2026.
//

import UIKit

class SecurityViewController: UIViewController {
    
    var viewModel: SecurityViewModel
    
    init(viewModel: SecurityViewModel) {
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
        
        title = NSLocalizedString("security_title", tableName: "Security", comment: "")
        setupTableView()
    }
    
    func setupTableView() {
        
        tableView.register(
            SecurityOptionTableViewCell.self,
            forCellReuseIdentifier: SecurityOptionTableViewCell.identifier
        )
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

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
            
            self.viewModel.toggleChanged(to: value, from: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModel.didSelectRow(at: indexPath)
    }
}

extension SecurityViewController {
    func setupBindings() {
        
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            
            self.tableView.reloadData()
            
        }
    }
}
