//
//  CustomizeDashboardViewController.swift
//  Vault
//
//  Created by Miguel Solans on 04/06/2026.
//

import UIKit

final class CustomizeDashboardViewController: VaultBaseViewController {
    
    // MARK: - Dependencies
    
    private var viewModel: CustomizeDashboardViewModel
    
    init(viewModel: CustomizeDashboardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.backgroundColor = UIColor(resource: .background)
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
        view.backgroundColor = UIColor(resource: .background)
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
        
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

extension CustomizeDashboardViewController {
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            CustomizeDashboardTableViewCell.self,
            forCellReuseIdentifier: CustomizeDashboardTableViewCell.identifier
        )
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension CustomizeDashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CustomizeDashboardTableViewCell.identifier,
            for: indexPath) as! CustomizeDashboardTableViewCell
        
        let vm = viewModel.widget(at: indexPath)
        
        cell.configure(with: vm)
        
        cell.onToggleChanged = { [weak self] isOn in
            guard let self else { return }
            
            self.viewModel.updateVisibility(isVisible: isOn, at: indexPath)
        }
        
        return cell
    }
    
}
