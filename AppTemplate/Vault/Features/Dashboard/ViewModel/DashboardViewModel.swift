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

protocol DashboardViewModelDelegate: AnyObject {
    func didTapVaultSelector(_ viewModel: DashboardViewModel)
    func didTapAgent(_ viewModel: DashboardViewModel)
    func didTapOperationGroup(_ viewModel: DashboardViewModel, with filter: OperationsFilter)
    func didTapFeedback(_ viewModel: DashboardViewModel)
}

final class DashboardViewModel: NSObject {
    
    weak var delegate: DashboardViewModelDelegate?

    // MARK: - Dependencies
    
    private(set) var vault: VaultDTO
    
    private let dashboardUseCase: DashboardUseCase
    
    private let foundationModelManager: FoundationModelAvailability
    
    private(set) var filter: OperationsFilter;
    
    init(
        dashboardUseCase: DashboardUseCase,
        vault: VaultDTO,
        filter: OperationsFilter,
        foundationModelManager: FoundationModelAvailability
    ) {
        self.dashboardUseCase = dashboardUseCase
        self.vault = vault
        self.filter = filter
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
    
    private(set) var summaryViewModel: AmountCardSectionViewModel?
    
    private(set) var statisticsSummaryViewModel: AmountCardSectionViewModel?
    
    private(set) var expensesPlotViewModel: ChartViewModel?
    
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
        
        do {
            
            let request = DashboardRequest(
                vaultID: filter.vault.id,
                startDate: filter.startDate,
                endDate: filter.endDate,
                period: filter.period
            )
            
            let response = try dashboardUseCase.execute(request)
            
            isVaultEmpty = response.isEmpty
            
            updateReimbursementsWarning(metrics: response.dashboardMetrics.reimbursements)
            
            updateGeneralSummary(metrics: response.dashboardMetrics)
            
            updateStatisticsSummary(metrics: response.dashboardMetrics)
            
            updateExpensesPlot(metrics: response.dashboardMetrics.categories)
            
            subtitle = currencyFormatter.string(
                from: response.dashboardMetrics.balance.currentBalance
            )
            
        } catch {
            onError?(.showAlert(message: "There was an error fetching data."))
        }
        
        updateUI?()
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

    private func updateGeneralSummary(metrics: DashboardMetrics) {
        
        let incomeViewModel = AmountCardItemViewModel(
            title: "Income",
            amount: metrics.cashFlow.income,
            type: .income
        )
        
        incomeViewModel.onTap = { [weak self] in
            guard let self = self else { return }
            
            self.didTapIncome()
        }
        
        let expenseViewModel = AmountCardItemViewModel(
            title: "Expenses",
            amount: metrics.netSpending.netExpenses,
            type: .expense
        )
        
        expenseViewModel.onTap = { [weak self] in
            guard let self = self else { return }
            
            self.didTapExpense()
        }
        
        summaryViewModel = AmountCardSectionViewModel(
            monthTitle: "",
            items: [ incomeViewModel, expenseViewModel ],
            gridFormat: true
        )
    }

    private func updateStatisticsSummary(metrics: DashboardMetrics) {
        let viewModel = AmountCardSectionViewModel(
            monthTitle: "Key metrics",
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
                    type: nil,
                    budgetAmount:nil
                )
            ],
            gridFormat: true
        )
        
        statisticsSummaryViewModel = viewModel
    }
    
    private func makeSummaryItem(
        emoji: String? = nil,
        title: String,
        amount: Double,
        type: OperationType?,
        budgetAmount: Double?
    ) -> AmountCardItemViewModel {
        let item = AmountCardItemViewModel(
            emoji: emoji,
            title: title,
            amount: amount,
            type: type
        )
        
        return item
    }
    
    private func updateExpensesPlot(metrics: CategoryMetrics) {
        
        let viewModel = ChartViewModel(
            title: "Where your money went",
            items: metrics.netExpenses,
            chartType: .pie,
            subtitle: currencyFormatter.string(from: metrics.totalNetExpenses) ?? ""
        )
        
        expensesPlotViewModel = viewModel
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
