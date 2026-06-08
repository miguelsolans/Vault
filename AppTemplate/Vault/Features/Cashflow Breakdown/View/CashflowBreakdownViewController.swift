//
//  CashflowBreakdownViewController.swift
//  Vault
//
//  Created by Miguel Solans on 08/05/2026.
//

import UIKit
import CoreKit
import AppUIKit

final class CashflowBreakdownViewController: VaultBaseViewController {
    
    // MARK: - Dependencies
    
    private(set) var viewModel: CashflowBreakdownViewModel
    
    init(viewModel: CashflowBreakdownViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = false
        return scroll
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var headerView: AmountStatusHeaderView = {
        let view = AmountStatusHeaderView()
        
        view.isHidden = viewModel.headerHidden
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var plotCardView: ChartCardView = {
        let view = ChartCardView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var summaryView: AmountCardSectionView = {
        let view = AmountCardSectionView()
        
        view.isHidden = viewModel.categoriesHidden
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var additionalMetricsView: AmountCardSectionView = {
        let view = AmountCardSectionView()
        
        view.isHidden = viewModel.additionalMetricsHidden
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
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
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
        view.backgroundColor = UIColor(resource: .background)
        setupScrollView()
        setupStackView()
        setupConstraints()
    }
    
    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            
            self.updateUI()
        }
        
        viewModel.onSuccess = { [weak self] feedback in
            guard let self else { return }
            
            self.notifyFeedback(.success)
        }
        
        viewModel.onError = { [weak self] feedback in
            guard let self else { return }
            
            switch feedback {
            case .showAlert(let message):
                self.presentAlert(with: L10n.Common.error, and: message)

            case .silent:
                break
            }
            
            self.notifyFeedback(.error)
        }
    }
}

// MARK: - UI Setup

extension CashflowBreakdownViewController {
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
    }
    
    private func setupStackView() {
        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(plotCardView)
        contentStack.addArrangedSubview(additionalMetricsView)
        contentStack.addArrangedSubview(summaryView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
}

// MARK: - UI Updates

extension CashflowBreakdownViewController {
    
    private func updateUI() {
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
        updateHeaderUI()
        updatePlotUI()
        updateCategoriesUI()
        updateMetricsUI()
    }
    
    private func updateHeaderUI() {
        if let viewModel = viewModel.headerViewModel {
            headerView.configure(with: viewModel)
        }
        
        headerView.isHidden = viewModel.headerHidden
    }
    
    private func updatePlotUI() {
        if let viewModel = viewModel.plotViewModel {
            plotCardView.configure(
                title: viewModel.title,
                subtitle: viewModel.subtitle,
                plotViewModel: viewModel,
                parentViewController: self
            )
        }
    }
    
    private func updateCategoriesUI() {
        if let viewModel = viewModel.categoriesViewModel {
            summaryView.configure(with: viewModel)
        }
        
        summaryView.isHidden = viewModel.categoriesHidden
    }
    
    private func updateMetricsUI() {
        if let viewModel = viewModel.additionalMetricsViewModel {
            additionalMetricsView.configure(with: viewModel)
        }
        
        additionalMetricsView.isHidden = viewModel.additionalMetricsHidden
    }
}
