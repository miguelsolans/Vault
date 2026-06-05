//
//  DashboardViewController.swift
//  Vault
//
//  Created by Miguel Solans on 01/04/2026.
//

import UIKit
import AppUIKit

final class DashboardViewController: VaultBaseViewController {
    
    // MARK: - Dependencies
    
    private(set) var viewModel: DashboardViewModel
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    lazy var feedbackView: FeedbackView = {
        let view = FeedbackView(
            viewModel: viewModel.feedbackViewModel,
            style: FeedbackStyles.informativeFeedback
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        return view
    }()
    
    lazy var monthSelectorView: MonthSelectorView = {
        let view = MonthSelectorView(viewModel: viewModel.monthSelectorViewModel)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 46).isActive = true
        
        return view;
    }();
    
    private lazy var emptyStateView: UIContentUnavailableView = {
        let view = makeEmptyContentView(
            with: noDataEmptyContentConfiguration(),
            minimumHeight: 360
        )
        
        view.isHidden = true
        
        return view
    }()
    
    private lazy var incomeAndSpendingSectionView: AmountCardSectionView = {
        let view = AmountCardSectionView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var mainAndOtherIncomeSectionView: AmountCardSectionView = {
        let view = AmountCardSectionView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var spendingCategoriesPieChartView: ChartCardView = {
        let view = ChartCardView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var incomeCategoriesPieChartView: ChartCardView = {
        let view = ChartCardView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var spendingCategoriesBarChartView: ChartCardView = {
        let view = ChartCardView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var incomeCategoriesBarChartView: ChartCardView = {
        let view = ChartCardView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var keyMetricsSectionView: AmountCardSectionView = {
        let view = AmountCardSectionView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var spendingBreakdownSectionView: AmountCardSectionView = {
        let view = AmountCardSectionView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var incomeBreakdownSectionView: AmountCardSectionView = {
        let view = AmountCardSectionView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    
    private lazy var customizeButton: UIButton = {
        let button = UIButton()
        
        button.apply(
            style: ButtonStyles.secondary,
            title: "Customize Dashboard"
        )
        
        button.configuration?.image = UIImage(systemName: "slider.horizontal.3")
        
        return button
    }()
    
    private  lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        
        return scroll
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
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
        setupNavigationItems()
        setupScrollView()
        setupStackView()
        setupConstraints()
        setupGestures()
    }
    
    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self else { return }
            
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
                self.presentAlert(with:"Error", and: message)

            case .silent:
                break
            }
            
            self.notifyFeedback(.error)
        }
    }
}

// MARK: - UI Setup

extension DashboardViewController {
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
    }
    
    private func setupStackView() {
        contentStack.addArrangedSubview(feedbackView)
        contentStack.addArrangedSubview(monthSelectorView)
        contentStack.addArrangedSubview(emptyStateView)
        
        contentStack.addArrangedSubview(incomeAndSpendingSectionView)
        contentStack.addArrangedSubview(spendingCategoriesPieChartView)
        contentStack.addArrangedSubview(mainAndOtherIncomeSectionView)
        contentStack.addArrangedSubview(incomeCategoriesPieChartView)
        contentStack.addArrangedSubview(spendingCategoriesBarChartView)
        contentStack.addArrangedSubview(incomeCategoriesBarChartView)
        contentStack.addArrangedSubview(keyMetricsSectionView)
        contentStack.addArrangedSubview(spendingBreakdownSectionView)
        contentStack.addArrangedSubview(incomeBreakdownSectionView)
        
        contentStack.addArrangedSubview(customizeButton)
    }
    
    private func setupConstraints() {
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
    
    private func setupNavigationItems() {
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
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFeedback))
        
        feedbackView.addGestureRecognizer(tapGesture)
        
        customizeButton.addTarget(self, action: #selector(didTapCustomize), for: .touchUpInside)
    }
}

// MARK: - Actions

extension DashboardViewController {
    @objc private func didTapVaultSelector() {
        viewModel.didTapVaultSelector()
    }
    
    @objc private func didTapAgent() {
        viewModel.didTapAgent()
    }
    
    @objc private func didTapFeedback() {
        viewModel.didTapFeedback()
    }
    
    @objc private func didTapCustomize() {
        viewModel.didTapCustomize()
    }
}

extension DashboardViewController {
    
    private func updateUI() {
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
        updateMonthSelectorUI()
        
        updateWidgetUI()
        
        setupNavigationItems()
        setupContentUnavailable()
    }
    
    private func updateMonthSelectorUI() {
        let shouldHide = viewModel.filter.period == .yearly
        
        monthSelectorView.isHidden = shouldHide
    }
    
    private func updateWidgetUI() {
        
        feedbackView.isHidden = viewModel.isFeedbackHidden
        
        if let viewModel = viewModel.incomeAndSpendingSectionViewModel {
            incomeAndSpendingSectionView.configure(with: viewModel)
            incomeAndSpendingSectionView.isHidden = self.viewModel.isVaultEmpty
        } else {
            incomeAndSpendingSectionView.isHidden = true
        }
        
        if let viewModel = viewModel.mainAndOtherIncomeSectionViewModel {
            mainAndOtherIncomeSectionView.configure(with: viewModel)
            mainAndOtherIncomeSectionView.isHidden = self.viewModel.isVaultEmpty
        } else {
            mainAndOtherIncomeSectionView.isHidden = true
        }
        
        if let viewModel = viewModel.spendingCategoriesPieChartViewModel {
            spendingCategoriesPieChartView.configure(
                title: viewModel.title,
                subtitle: viewModel.subtitle,
                plotViewModel: viewModel,
                parentViewController: self
            )
            spendingCategoriesPieChartView.isHidden = self.viewModel.isVaultEmpty
        } else {
            spendingCategoriesPieChartView.isHidden = true
        }
        
        if let viewModel = viewModel.incomeCategoriesPieChartViewModel {
            incomeCategoriesPieChartView.configure(
                title: viewModel.title,
                subtitle: viewModel.subtitle,
                plotViewModel: viewModel,
                parentViewController: self
            )
            incomeCategoriesPieChartView.isHidden = self.viewModel.isVaultEmpty
        } else {
            incomeCategoriesPieChartView.isHidden = true
        }
        
        if let viewModel = viewModel.spendingCategoriesBarChartViewModel {
            spendingCategoriesBarChartView.configure(
                title: viewModel.title,
                subtitle: viewModel.subtitle,
                plotViewModel: viewModel,
                parentViewController: self
            )
            spendingCategoriesBarChartView.isHidden = self.viewModel.isVaultEmpty
        } else {
            spendingCategoriesBarChartView.isHidden = true
        }
        
        if let viewModel = viewModel.incomeCategoriesBarChartViewModel {
            incomeCategoriesBarChartView.configure(
                title: viewModel.title,
                subtitle: viewModel.subtitle,
                plotViewModel: viewModel,
                parentViewController: self
            )
            incomeCategoriesBarChartView.isHidden = self.viewModel.isVaultEmpty
        } else {
            incomeCategoriesBarChartView.isHidden = true
        }
        
        if let viewModel = viewModel.keyMetricsSectionViewModel {
            keyMetricsSectionView.configure(with: viewModel)
            keyMetricsSectionView.isHidden = self.viewModel.isVaultEmpty
        } else {
            keyMetricsSectionView.isHidden = true
        }
        
        if let viewModel = viewModel.spendingBreakdownSectionViewModel {
            spendingBreakdownSectionView.configure(with: viewModel)
            spendingBreakdownSectionView.isHidden = self.viewModel.isVaultEmpty
        } else {
            spendingBreakdownSectionView.isHidden = true
        }
        
        if let viewModel = viewModel.incomeBreakdownSectionViewModel {
            incomeBreakdownSectionView.configure(with: viewModel)
            incomeBreakdownSectionView.isHidden = self.viewModel.isVaultEmpty
        } else {
            incomeBreakdownSectionView.isHidden = true
        }
        
        customizeButton.isHidden = viewModel.emptyContent != nil
    }
}

extension DashboardViewController {
    private func setupContentUnavailable() {
        contentUnavailableConfiguration = nil
        updateEmptyContentView(
            emptyStateView,
            with: emptyContentConfiguration()
        )
    }
    
    private func emptyContentConfiguration() -> EmptyContentConfiguration? {
        switch viewModel.emptyContent {
        case .noData:
            return noDataEmptyContentConfiguration()
            
        case .noWidgets:
            return noWidgetsEmptyContentConfiguration()
            
        case .none:
            return nil
        }
    }
    
    private func noDataEmptyContentConfiguration() -> EmptyContentConfiguration {
        EmptyContentConfiguration(
            image: UIImage(systemName: "list.bullet"),
            title: "No data",
            message: "There is no data to calculate Vault metrics.\nYou can add financial data in Operations."
        )
    }
    
    private func noWidgetsEmptyContentConfiguration() -> EmptyContentConfiguration {
        EmptyContentConfiguration(
            image: UIImage(systemName: "rectangle.grid.2x2"),
            title: "No widgets",
            message: "Choose the information you want to see in your Dashboard.",
            buttonTitle: "Customize Dashboard",
            buttonImage: UIImage(systemName: "slider.horizontal.3"),
            buttonAction: { [weak self] in
                self?.viewModel.didTapCustomize()
            }
        )
    }
}
