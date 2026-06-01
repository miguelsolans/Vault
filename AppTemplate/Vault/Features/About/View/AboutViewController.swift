//
//  AboutViewController.swift
//  Vault
//
//  Created by Miguel Solans on 01/06/2026.
//

import UIKit

final class AboutViewController: VaultBaseViewController {
    
    // MARK: - Dependencies
    
    private(set) var viewModel: AboutViewModel
    
    init(
        viewModel: AboutViewModel
    ) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func setupUI() {
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
        view.backgroundColor = UIColor(resource: .background)
        setupTableView()
        setupConstraints()
    }
    
    private func updateUI() {
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
    }
    
    override func setupBindings() {
        
    }
}

extension AboutViewController {
    
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

extension AboutViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows(at: section)
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
        
        viewModel.didSelectRowAtIndex(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeader(in: section)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return viewModel.titleForFooter(in: section)
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        
        footer.textLabel?.textAlignment = .center
    }
}
