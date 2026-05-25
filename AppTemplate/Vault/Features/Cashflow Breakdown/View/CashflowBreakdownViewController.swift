//
//  CashflowBreakdownViewController.swift
//  Vault
//
//  Created by Miguel Solans on 08/05/2026.
//

import UIKit
import CoreKit
import AppUIKit

final class CashflowBreakdownViewController: BaseViewController {
     
    private(set) var viewModel: CashflowBreakdownViewModel
    
    init(viewModel: CashflowBreakdownViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    
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
    
    private lazy var amountHeaderView: AmountStatusHeaderView = {
        let view = AmountStatusHeaderView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var plotCardView: ChartCardView = {
        let view = ChartCardView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var categoriesSummaryView: AmountCardSectionView = {
        let view = AmountCardSectionView()
        
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
        setupScroll()
        setupStackItems()
    }
    
    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            self.updateUI()
        }
    }
}

extension CashflowBreakdownViewController {
    private func setupScroll() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
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
    
    private func setupStackItems() {
        contentStack.addArrangedSubview(amountHeaderView)
        contentStack.addArrangedSubview(plotCardView)
        contentStack.addArrangedSubview(categoriesSummaryView)
    }
}

extension CashflowBreakdownViewController {
    private func updateUI() {
        
        if let viewModel = viewModel.amountHeaderViewModel {
            amountHeaderView.configure(with: viewModel)
            
            amountHeaderView.isHidden = false
        } else {
            amountHeaderView.isHidden = true
        }
        
        if let viewModel = viewModel.plotViewModel {
            plotCardView.configure(
                title: viewModel.title,
                subtitle: viewModel.subtitle,
                plotViewModel: viewModel,
                parentViewController: self
            )
            
            plotCardView.isHidden = false
        } else {
            plotCardView.isHidden = true
        }
        
        if let viewModel = viewModel.categoriesViewModel {
            
            categoriesSummaryView.configure(with: viewModel)
            
            categoriesSummaryView.isHidden = false
        } else {
            categoriesSummaryView.isHidden = true
        }
    }
}
