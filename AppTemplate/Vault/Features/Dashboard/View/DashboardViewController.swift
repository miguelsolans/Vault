//
//  DashboardViewController.swift
//  Vault
//
//  Created by Miguel Solans on 01/04/2026.
//

import UIKit
import AppUIKit

final class DashboardViewController: UIViewController {
    
    private(set) var viewModel: DashboardViewModel
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    
    lazy var feedbackView: FeedbackView = {
        let view = FeedbackView(viewModel: viewModel.feedbackViewModel, style: FeedbackStyles.informativeFeedback)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        return view
    }()
    
    lazy var monthSelectorView: MonthSelectorView = {
        let view = MonthSelectorView(viewModel: viewModel.monthSelectorViewModel)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        return view;
    }();
    
    private lazy var emptyStateView: UIContentUnavailableView = {
        var config = UIContentUnavailableConfiguration.empty()
        config.background.backgroundColor = .systemBackground
        config.image = UIImage(systemName: "tag")
        config.text = "No data"
        config.secondaryText = "There is no data to calculate Vault metrics.\nYou can add financial data in Operations."
        
        let view = UIContentUnavailableView(configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: 360).isActive = true
        return view
    }()
    
    lazy var cashflowCardSectionView: AmountCardSectionView = {
        let view = AmountCardSectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var expensesChartCard: ChartCardView = {
        let view = ChartCardView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var statisticsSummaryView: AmountCardSectionView = {
        let view = AmountCardSectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationItems()
        setupScrollStack()
        setupStackItems()
        setupBindings()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.getData()
    }
    
    private func setupGestures() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFeedback))
        
        feedbackView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup ScrollView + Stack
    func setupScrollStack() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
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
    
    // MARK: - Navigation
    func setupNavigationItems() {
        title = viewModel.title
        
        navigationItem.subtitle = viewModel.subtitle
        
        var leftBarButtonItems = [UIBarButtonItem]()
        
        let vaultSelectorButton = UIBarButtonItem(
            image: UIImage(systemName: "square.stack"),
            style: .plain,
            target: self,
            action: #selector(didTapVaultSelector)
        )
        
        leftBarButtonItems.append(vaultSelectorButton)
        
        if viewModel.isChatAvailable {
            let assistantButton = UIBarButtonItem(
                image: UIImage(systemName: "apple.intelligence"),
                style: .plain,
                target: self,
                action: #selector(didTapAgent)
            )
            
            leftBarButtonItems.append(assistantButton)
        }
        
        navigationItem.leftBarButtonItems = leftBarButtonItems
        
        let yearlyAction = UIAction(
            title: "Yearly",
            state: viewModel.filter.period == .yearly ? .on : .off
        ) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.applyPeriod(.yearly)
        }
        
        let monthlyAction = UIAction(
            title: "Monthly",
            state: viewModel.filter.period == .monthly ? .on : .off
        ) { [weak self] _ in
            guard let self = self else { return }
            
            self.viewModel.applyPeriod(.monthly)
        }
        
        let filterMenu = UIMenu(title: "", options: .singleSelection, children: [yearlyAction, monthlyAction])
        
        let filterBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3.decrease.circle"),
            menu: filterMenu
        )
        
        navigationItem.rightBarButtonItem = filterBarButtonItem
    }
    
    @objc private func didTapVaultSelector() {
        viewModel.didTapVaultSelector()
    }
    
    @objc private func didTapAgent() {
        viewModel.didTapAgent()
    }
    
    private func didTapFilter() {
        
    }
    
    @objc private func didTapFeedback() {
        viewModel.didTapFeedback()
    }
    
    // MARK: - Summary UI
    func setupStackItems() {
        contentStack.addArrangedSubview(feedbackView)
        contentStack.addArrangedSubview(monthSelectorView)
        contentStack.addArrangedSubview(emptyStateView)
        contentStack.addArrangedSubview(cashflowCardSectionView)
        contentStack.addArrangedSubview(expensesChartCard)
        contentStack.addArrangedSubview(statisticsSummaryView)
    }
}

extension DashboardViewController {
    func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            self.updateMonthSelectorUI()
            self.updateSummaryUI()
            self.updateChartUI()
            self.setupNavigationItems()
            self.setupContentUnavailable()
        }

        viewModel.getData()
    }
    
    func updateMonthSelectorUI() {
        let shouldHide = viewModel.filter.period == .yearly
        
        monthSelectorView.isHidden = shouldHide
    }
    
    func updateSummaryUI() {
        
        feedbackView.isHidden = viewModel.isFeedbackHidden
        cashflowCardSectionView.isHidden = viewModel.isVaultEmpty
        statisticsSummaryView.isHidden = viewModel.isVaultEmpty
        
        if let yearlyViewModel = viewModel.summaryViewModel {
            cashflowCardSectionView.configure(with: yearlyViewModel)
            cashflowCardSectionView.setNeedsLayout()
            cashflowCardSectionView.layoutIfNeeded()
        }
        
        if let statisticsViewModel = viewModel.statisticsSummaryViewModel {
            statisticsSummaryView.configure(with: statisticsViewModel)
            statisticsSummaryView.setNeedsLayout()
            statisticsSummaryView.layoutIfNeeded()
        }
    }
    
    func updateChartUI() {
        expensesChartCard.isHidden = viewModel.isVaultEmpty
        
        guard !viewModel.isVaultEmpty else { return }
        
        if let viewModel = viewModel.expensesPlotViewModel {
            expensesChartCard.configure(
                title: viewModel.title,
                subtitle: viewModel.subtitle,
                plotViewModel: viewModel,
                parentViewController: self
            )
            
            expensesChartCard.isHidden = false
        } else {
            expensesChartCard.isHidden = false
        }
    }
    
    func setupContentUnavailable() {
        contentUnavailableConfiguration = nil
        emptyStateView.isHidden = !viewModel.isVaultEmpty
    }
}
