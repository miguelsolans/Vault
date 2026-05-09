//
//  DashboardViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 01/04/2026.
//


// Cashflow: Income, Expenses
// Expenses plot
// Key metrics: Average income, Average spent, Total saved, Saving efficiency

import AppUIKit
import CoreData
import SwiftUI
import FoundationModels
import VaultCore

protocol DashboardViewModelDelegate: AnyObject {
    func didTapVaultSelector(_ viewModel: DashboardViewModel)
    func didTapAgent(_ viewModel: DashboardViewModel)
    func didTapOperationGroup(_ viewModel: DashboardViewModel, with filter: OperationsFilter)
}

public final class DashboardViewModel: NSObject {
    
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

    // MARK: - Data State
    
    private(set) var dashboardMetrics: DashboardMetrics?

    // MARK: - UI State
    
    public var title: String {
        get {
            "Overview"
        }
    }

    public var subtitle: String? {
        get {
            let currentBalance = dashboardMetrics?.balance.currentBalance ?? vault.currentBalance
            
            return currencyFormatter.string(
                from: currentBalance
            )
        }
    }
    
    public var isChatAvailable: Bool {
        get {
            return foundationModelManager.isSupported
        }
    }
    
    private lazy var currencyFormatter = {
        LocalizedDecimalFormatter(numberStyle: .currency)
    }()
    
    public var isVaultEmpty: Bool = true
    
    private(set) var feedbackViewModel: FeedbackViewModel = {
        return FeedbackViewModel(title: "", subtitle: "", feedbackType: .informative)
    }()
    
    public var isFeedbackHidden: Bool {
        get {
            guard let dashboardMetrics else {
                return true
            }
            
            return dashboardMetrics.reimbursements.expected <= 0
        }
    }
    
    private(set) var summaryViewModel: AmountCardSectionViewModel?
    
    private(set) var statisticsSummaryViewModel: AmountCardSectionViewModel?
    
    private(set) var expensesPlotViewModel: ChartViewModel?
    
    private(set) var monthSelectorViewModel: MonthSelectorViewModel = {
        let viewModel = MonthSelectorViewModel();
        
        return viewModel
    }();

    // MARK: - Binding

    var updateUI: (() -> Void)?
    
}

// MARK: - Public API
extension DashboardViewModel {
    
    func applyPeriod(_ period: Period) {
        
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
    
    func applyFilter(_ filter: OperationsFilter) {
        self.filter = filter
        
        getData()
    }

    func getData() {
        
        do {
            
            let request = DashboardRequest(
                vaultID: filter.vault.id,
                startDate: filter.startDate,
                endDate: filter.endDate,
                period: filter.period
            )
            
            let response = try dashboardUseCase.execute(request)
            
            isVaultEmpty = response.isEmpty
            
            dashboardMetrics = response.dashboardMetrics
            
            updateReimbursementsWarning(metrics: response.dashboardMetrics.reimbursements)
            
            summaryViewModel = makeGeneralSummary(metrics: response.dashboardMetrics)
            
            statisticsSummaryViewModel = makeStatisticsSummary(metrics: response.dashboardMetrics)
            
            expensesPlotViewModel = ChartViewModel(
                title: "Where your money went",
                items: response.dashboardMetrics.categories.netExpenses,
                chartType: .pie,
                subtitle: currencyFormatter.string(from: response.dashboardMetrics.categories.totalNetExpenses) ?? ""
            )
            
        } catch {
            // TODO: Present error?
        }
        
        updateUI?()
    }
    
}

// MARK: - View Model Builders
private extension DashboardViewModel {
    
    func updateReimbursementsWarning(metrics: ReimbursementMetrics) {
        
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
    }

    func makeGeneralSummary(metrics: DashboardMetrics) -> AmountCardSectionViewModel {
        
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
        
        return AmountCardSectionViewModel(
            monthTitle: "",
            items: [ incomeViewModel, expenseViewModel ],
            gridFormat: true
        )
    }

    func makeStatisticsSummary(metrics: DashboardMetrics) -> AmountCardSectionViewModel {
        AmountCardSectionViewModel(
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
    }
    
    func makeSummaryItem(
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
}

// MARK: - Actions
extension DashboardViewModel {
    func didTapVaultSelector() {
        delegate?.didTapVaultSelector(self)
    }
    
    func didTapAgent() {
        delegate?.didTapAgent(self)
    }
    
    func didTapIncome() {
        let filter = OperationsFilter(
            startDate: filter.startDate,
            endDate: filter.endDate,
            type: .income,
            period: filter.period,
            vault: vault
        )
        
        delegate?.didTapOperationGroup(self, with: filter)
    }
    
    func didTapExpense() {
        let filter = OperationsFilter(
            startDate: filter.startDate,
            endDate: filter.endDate,
            type: .expense,
            period: filter.period,
            vault: vault
        )
        
        delegate?.didTapOperationGroup(self, with: filter)
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
