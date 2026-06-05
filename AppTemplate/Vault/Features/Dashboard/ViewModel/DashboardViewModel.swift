//
//  DashboardViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 01/04/2026.
//

import Foundation
import AppUIKit
import CoreKit
import FoundationModels
import VaultCore

enum DashboardEmptyContent {
    case noData
    case noWidgets
}

protocol DashboardViewModelDelegate: AnyObject {
    func didTapVaultSelector(_ viewModel: DashboardViewModel)
    func didTapAgent(_ viewModel: DashboardViewModel)
    func didTapOperationGroup(_ viewModel: DashboardViewModel, with filter: OperationsFilter)
    func didTapFeedback(_ viewModel: DashboardViewModel)
    func didTapCustomize(_ viewModel: DashboardViewModel)
    func presentMarketing(_ viewModel: DashboardViewModel)
}

final class DashboardViewModel: NSObject {
    
    weak var delegate: DashboardViewModelDelegate?

    // MARK: - Dependencies
    
    private(set) var vault: VaultDTO
    
    private(set) var filter: OperationsFilter
    
    private let vaultDashboardUseCase: GetVaultDashboardUseCase
    
    private let statisticsUseCase: StatisticsUseCase
    
    private let foundationModelManager: FoundationModelAvailability
    
    init(
        vault: VaultDTO,
        filter: OperationsFilter,
        vaultDashboardUseCase: GetVaultDashboardUseCase,
        statisticsUseCase: StatisticsUseCase,
        foundationModelManager: FoundationModelAvailability
    ) {
        self.vault = vault
        self.filter = filter
        self.vaultDashboardUseCase = vaultDashboardUseCase
        self.statisticsUseCase = statisticsUseCase
        self.foundationModelManager = foundationModelManager
        super.init()
        self.setupBindings()
    }

    // MARK: - UI
    
    public var title: String {
        get {
            "Overview"
        }
    }

    private(set) var subtitle: String?
    
    public var isChatAvailable: Bool {
        get {
            return false
        }
    }
    
    private(set) var isVaultEmpty: Bool = true
    
    var emptyContent: DashboardEmptyContent? {
        if widgets.isEmpty {
            return .noWidgets
        }
        
        if isVaultEmpty {
            return .noData
        }
        
        return nil
    }
    
    private(set) var isFeedbackHidden: Bool = true
    
    private(set) var feedbackViewModel: FeedbackViewModel = {
        return FeedbackViewModel(
            title: "",
            subtitle: "",
            feedbackType: .informative
        )
    }()
    
    private(set) var monthSelectorViewModel: MonthSelectorViewModel = {
        let viewModel = MonthSelectorViewModel();
        
        return viewModel
    }();
    
    private(set) var incomeAndSpendingSectionViewModel: AmountCardSectionViewModel?
    
    private(set) var mainAndOtherIncomeSectionViewModel: AmountCardSectionViewModel?
    
    private(set) var spendingCategoriesPieChartViewModel: ChartViewModel?
    
    private(set) var incomeCategoriesPieChartViewModel: ChartViewModel?
    
    private(set) var spendingCategoriesBarChartViewModel: ChartViewModel?
    
    private(set) var incomeCategoriesBarChartViewModel: ChartViewModel?
    
    private(set) var keyMetricsSectionViewModel: AmountCardSectionViewModel?
    
    private(set) var incomeBreakdownSectionViewModel: AmountCardSectionViewModel?
    
    private(set) var spendingBreakdownSectionViewModel: AmountCardSectionViewModel?
    
    // MARK: - Data
    
    private(set) var widgets: [DashboardWidgetDTO] = []
    
    // MARK: - Formatters
    
    private lazy var currencyFormatter = {
        LocalizedDecimalFormatter(numberStyle: .currency)
    }()
    
    // MARK: - Binding

    public var updateUI: (() -> Void)?
    
    public var onSuccess: ((ViewModelFeedback) -> Void)?
    
    public var onError: ((ViewModelFeedback) -> Void)?
    
}

// MARK: - Data
extension DashboardViewModel {
    
    public func getData() {
        resetPresentation()
        getDashboardConfiguration()
    }
    
    private func getDashboardConfiguration() {
        
        do {
            
            let request = GetVaultDashboardRequest(
                vaultID: filter.vault.id
            )
            
            let response = try vaultDashboardUseCase.execute(request)
            
            if response.presentMarketing {
                delegate?.presentMarketing(self)
            }
            
            widgets = response.dashboard.widgets
                .filter { $0.isVisible }
            
            getStatistics()
            
        } catch {
            onError?(.showAlert(message: "There was an error fetching dashboard configuration"))
        }
    }
    
    private func getStatistics() {
        do {
            let request = StatisticsRequest(
                vaultID: filter.vault.id,
                startDate: filter.startDate,
                endDate: filter.endDate,
                period: filter.period
            )
            
            let response = try statisticsUseCase.execute(request)
            
            isVaultEmpty = response.metrics.period.isEmpty
            
            makeWidgetPresentation(metrics: response.metrics)
            
            updateReimbursementsWarning(metrics: response.metrics.reimbursements)
            
            subtitle = currencyFormatter.string(
                from: response.metrics.balance.currentBalance
            )
            
        } catch {
            onError?(.showAlert(message: "There was an error fetching data."))
        }
        
        updateUI?()
    }
    
    private func makeWidgetPresentation(metrics: VaultMetrics) {
        for widget in widgets {
            
            switch widget.type {
                
            case .totalIncomeAndSpending:
                makeIncomeAndSpendingSection(metrics: metrics)
                break
            case .totalMainAndOtherIncome:
                makeMainAndOtherIncomeSection(metrics: metrics)
                break
            case .pieChartSpendingCategories:
                makeSpendingCategoriesPieChart(metrics: metrics)
                break
            case .pieChartIncomeCategories:
                makeIncomeCategoriesPieChart(metrics: metrics)
                break
            case .barChartSpendingCategories:
                makeSpendingCategoriesBarChart(metrics: metrics)
                break
            case .barChartIncomeCategories:
                makeIncomeCategoriesBarChart(metrics: metrics)
                break
            case .keyMetrics:
                makeKeyMetricsSection(metrics: metrics)
                break
            case .incomeBreakdown:
                makeIncomeBreakdownSection(metrics: metrics)
                break
            case .spendingBreakdown:
                makeSpendingBreakdownSection(metrics: metrics)
                break
            case .unknown:
                break
            }
        }
    }
    
    private func resetPresentation() {
        widgets = []
        
        incomeAndSpendingSectionViewModel = nil
        
        mainAndOtherIncomeSectionViewModel = nil
        
        spendingCategoriesPieChartViewModel = nil
        
        incomeCategoriesPieChartViewModel = nil
        
        spendingCategoriesBarChartViewModel = nil
        
        incomeCategoriesBarChartViewModel = nil
        
        keyMetricsSectionViewModel = nil
        
        incomeBreakdownSectionViewModel = nil
        
        spendingBreakdownSectionViewModel = nil
    }
}

// MARK: - Actions

extension DashboardViewModel {
    
    public func didTapVaultSelector() {
        
        delegate?.didTapVaultSelector(self)
    }
    
    public func didTapAgent() {
        
        delegate?.didTapAgent(self)
    }
    
    public func didTapIncome() {
        
        let filter = OperationsFilter(
            startDate: filter.startDate,
            endDate: filter.endDate,
            type: .income,
            period: filter.period,
            vault: vault
        )
        
        delegate?.didTapOperationGroup(self, with: filter)
    }
    
    public func didTapExpense() {
        
        let filter = OperationsFilter(
            startDate: filter.startDate,
            endDate: filter.endDate,
            type: .expense,
            period: filter.period,
            vault: vault
        )
        
        delegate?.didTapOperationGroup(self, with: filter)
    }
    
    public func didTapFeedback() {
        
        delegate?.didTapFeedback(self)
    }
    
    public func didTapCustomize() {
        
        delegate?.didTapCustomize(self)
    }
}

// MARK: - Factory

extension DashboardViewModel {
    
    private func makeIncomeAndSpendingSection(metrics: VaultMetrics) {
        var items: [AmountCardItemViewModel] = []
        
        let totalIncomeViewModel = AmountCardItemViewModel(
            title: "Total income",
            amount: metrics.cashFlow.totalIncome,
            type: .income
        )
        
        totalIncomeViewModel.onTap = { [weak self] in
            guard let self = self else { return }
            
            self.didTapIncome()
        }
        
        items.append(totalIncomeViewModel)
        
        let expenseViewModel = AmountCardItemViewModel(
            title: "Total expenses",
            amount: metrics.netSpending.netExpenses,
            type: .expense
        )
        
        expenseViewModel.onTap = { [weak self] in
            guard let self = self else { return }
            
            self.didTapExpense()
        }
        
        items.append(expenseViewModel)
        
        incomeAndSpendingSectionViewModel = AmountCardSectionViewModel(
            items: items,
            gridFormat: true
        )
    }
    
    private func makeMainAndOtherIncomeSection(metrics: VaultMetrics) {
        var items: [AmountCardItemViewModel] = []
        
        let mainIncomeViewModel = AmountCardItemViewModel(
            title: "Main income",
            amount: metrics.cashFlow.mainIncome ?? 0,
            type: .income
        )
        
        items.append(mainIncomeViewModel)
        
        let otherIncomeViewModel = AmountCardItemViewModel(
            title: "Other income",
            amount: metrics.cashFlow.otherIncome ?? 0,
            type: .income
        )
        
        items.append(otherIncomeViewModel)
        
        mainAndOtherIncomeSectionViewModel = AmountCardSectionViewModel(
            items: items,
            gridFormat: true
        )
    }
    
    private func makeSpendingCategoriesPieChart(metrics: VaultMetrics) {
        let viewModel = ChartViewModel(
            title: "Where your money went",
            items: metrics.categories.netExpenses,
            chartType: .pie,
            subtitle: currencyFormatter.string(from: metrics.categories.totalNetExpenses) ?? ""
        )
        
        spendingCategoriesPieChartViewModel = viewModel
    }
    
    private func makeIncomeCategoriesPieChart(metrics: VaultMetrics) {
        let viewModel = ChartViewModel(
            title: "Where your money comes from",
            items: metrics.categories.income,
            chartType: .pie,
            subtitle: currencyFormatter.string(from: metrics.categories.totalIncome) ?? ""
        )
        
        incomeCategoriesPieChartViewModel = viewModel
    }
    
    private func makeSpendingCategoriesBarChart(metrics: VaultMetrics) {
        let viewModel = ChartViewModel(
            title: "Your expenses",
            items: metrics.categories.netExpenses,
            chartType: .bar,
            subtitle: currencyFormatter.string(from: metrics.categories.totalNetExpenses) ?? ""
        )
        
        spendingCategoriesBarChartViewModel = viewModel
    }
    
    private func makeIncomeCategoriesBarChart(metrics: VaultMetrics) {
        let viewModel = ChartViewModel(
            title: "Your income",
            items: metrics.categories.income,
            chartType: .bar,
            subtitle: currencyFormatter.string(from: metrics.categories.totalIncome) ?? ""
        )
        
        incomeCategoriesBarChartViewModel = viewModel
    }
    
    private func makeKeyMetricsSection(metrics: VaultMetrics) {
        let viewModel = AmountCardSectionViewModel(
            title: "Key metrics",
            items: [
                makeSummaryItem(
                    title: "Average income",
                    amount: metrics.cashFlow.averageIncome,
                    type: .income,
                    budgetAmount:nil
                ),
                makeSummaryItem(
                    title: "Average spent",
                    amount: metrics.cashFlow.averageExpense,
                    type: .expense,
                    budgetAmount:nil
                ),
                makeSummaryItem(
                    title: "Total saved",
                    amount: metrics.netSpending.savings,
                    type: nil,
                    budgetAmount:nil
                ),
                makeSummaryItem(
                    title: "Saving efficiency",
                    amount: metrics.netSpending.savingEfficiency,
                    numberStyle: .percent,
                    type: nil,
                    budgetAmount:nil
                )
            ],
            gridFormat: true
        )
        
        keyMetricsSectionViewModel = viewModel
    }
    
    private func makeSpendingBreakdownSection(metrics: VaultMetrics) {
        spendingBreakdownSectionViewModel = AmountCardSectionViewModel(
            title: "Spending breakdown",
            items: categorySummaryItems(from: metrics.categories.income),
            gridFormat: true
        )
    }
    
    private func makeIncomeBreakdownSection(metrics: VaultMetrics) {
        incomeBreakdownSectionViewModel = AmountCardSectionViewModel(
            title: "Income breakdown",
            items: categorySummaryItems(from: metrics.categories.netExpenses),
            gridFormat: true
        )
    }
    
    private func categorySummaryItems(from categories: [AmountPerCategory]) -> [AmountCardItemViewModel] {
        var items: [AmountCardItemViewModel] = []
        
        for category in categories {
            items.append(
                .init(
                    title: category.title,
                    amount: category.amount,
                    type: filter.type
                )
            )
        }
        
        items.sort {
            $0.amount > $1.amount
        }
        
        return items
    }
}

// MARK: - Helper

private extension DashboardViewModel {
    
    private func updateReimbursementsWarning(metrics: ReimbursementMetrics) {
        
        let titleText = "Pending Reimbursements"
        let formattedAmount = currencyFormatter.string(from: metrics.expected) ?? "\(metrics.expected)"
        let bodyText = "You are currently expecting reimbursements with a total value of \(formattedAmount)"
        
        feedbackViewModel.title = titleText
        feedbackViewModel.subtitle = bodyText;
        feedbackViewModel.subtitleAttributed = bodyText.styled(
            baseAttributes: [
                .font: FeedbackStyles.informativeFeedback.subtitleFont,
                .foregroundColor: FeedbackStyles.informativeFeedback.subtitleColor
            ],
            highlights: [
                TextHighlight(text: formattedAmount, attributes: [
                    .font: AppFonts.feedbackBodyBold
                ])
            ]
        )
        
        feedbackViewModel.feedbackType = .warning
        
        isFeedbackHidden = metrics.expected <= 0
    }
    
    private func makeSummaryItem(
        emoji: String? = nil,
        title: String,
        amount: Double,
        numberStyle: NumberFormatter.Style = .currency,
        type: OperationType?,
        budgetAmount: Double?
    ) -> AmountCardItemViewModel {
        let item = AmountCardItemViewModel(
            emoji: emoji,
            title: title,
            amount: amount,
            numberStyle: numberStyle,
            type: type
        )
        
        return item
    }
}

// MARK: - Filter

extension DashboardViewModel {
    public func applyPeriod(_ period: Period) {
        
        let startDate = period == .monthly ? Date().monthStart() : Date().yearStart()
        let endDate = period == .monthly ? Date().monthEnd() : Date().yearEnd()
        
        let filter = OperationsFilter(
            startDate: startDate,
            endDate: endDate,
            period: period,
            vault: vault
        )
        
        self.applyFilter(filter)
    }
    
    public func applyFilter(_ filter: OperationsFilter) {
        self.filter = filter
        
        getData()
    }
}


// MARK: - Bindings
extension DashboardViewModel {
    private func setupBindings() {
        monthSelectorViewModel.onMonthChanged = { [weak self] _ in
            guard let self = self else { return }
            
            self.filter.startDate = self.monthSelectorViewModel.currentDate.monthStart()
            self.filter.endDate = self.monthSelectorViewModel.currentDate.monthEnd()
            
            self.getData()
        }
    }
}
