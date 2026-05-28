//
//  CashflowBreakdownViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 08/05/2026.
//

import Foundation
import CoreKit
import VaultCore

final class CashflowBreakdownViewModel: NSObject {

    // MARK: - Dependencies
    private(set) var filter: OperationsFilter
    
    private let useCase: DashboardUseCase;
    
    init(
        filter: OperationsFilter,
        useCase: DashboardUseCase
    ) {
        self.useCase = useCase
        self.filter = filter
        super.init()
    }
    
    // MARK: - UI State
    
    public var title: String {
        switch filter.type {
        case .income:
            "Income"
        case .expense:
            "Spending"
        case .none:
            ""
        }
    }
    
    private(set) var subtitle: String? = nil
    
    private(set) var headerViewModel: AmountStatusHeaderViewModel?
    
    private(set) var plotViewModel: ChartViewModel?
    
    private(set) var categoriesViewModel: AmountCardSectionViewModel?
    
    private(set) var additionalMetricsViewModel: AmountCardSectionViewModel?
    
    private(set) var headerHidden: Bool = true
    
    private(set) var categoriesHidden: Bool = true
    
    private(set) var additionalMetricsHidden: Bool = true
    
    // MARK: - Bindings
    
    public var updateUI: (() -> Void)?
    
    public var onSuccess: ((ViewModelFeedback) -> Void)?
    
    public var onError: ((ViewModelFeedback) -> Void)?
}

extension CashflowBreakdownViewModel {
    public func getData() {
        let request = DashboardRequest(
            vaultID: filter.vault.id,
            startDate: filter.startDate,
            endDate: filter.endDate,
            period: filter.period
        )
        
        do {
            let response = try useCase.execute(request)
            
            let total = filter.type == .income ?
                response.dashboardMetrics.cashFlow.totalIncome :
                response.dashboardMetrics.netSpending.netExpenses
            
            let isEmpty = total == 0
            
            let percentage = filter.type == .income ?
                response.dashboardMetrics.cashFlow.incomeChangeFromPreviousMonth :
                response.dashboardMetrics.cashFlow.expensesChangeFromPreviousMonth
            
            let items = filter.type == .income ?
                response.dashboardMetrics.categories.income :
                response.dashboardMetrics.categories.netExpenses
            
            let average = filter.type == .income ?
                response.dashboardMetrics.cashFlow.averageIncome :
                response.dashboardMetrics.cashFlow.averageExpense
            
            headerViewModel = AmountStatusHeaderViewModel(
                amount: total,
                percentage: percentage?.value ?? 0.00,
                operationType: filter.type ?? .income,
                period: filter.period
            )
            
            plotViewModel = ChartViewModel(
                title: "",
                items: items,
                chartType: .bar,
                subtitle: "",
                average: average
            )
            
            categoriesViewModel = AmountCardSectionViewModel(
                monthTitle: "Breakdown",
                items: categorySummaryItems(from: items),
                gridFormat: true
            )
            
            additionalMetricsViewModel = AmountCardSectionViewModel(
                monthTitle: "",
                items: additionalMetricItems(from: response.dashboardMetrics.cashFlow),
                gridFormat: true
            )
            
            headerHidden = isEmpty
            
            categoriesHidden = isEmpty
            
            additionalMetricsHidden = filter.type == .expense || isEmpty
            
        } catch {
            
            onError?(.showAlert(message: "There was an error fetching data."))
        }
        
        updateUI?()
    }
}

extension CashflowBreakdownViewModel {
    
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
    
    private func additionalMetricItems(from cashFlow: CashFlowMetrics) -> [AmountCardItemViewModel] {
        var items: [AmountCardItemViewModel] = []
        
        if let mainIncome = cashFlow.mainIncome {
            let mainIncomeViewModel = AmountCardItemViewModel(
                title: "Main income",
                amount: mainIncome,
                type: .income
            )
            
            items.append(mainIncomeViewModel)
        }
        
        if let otherIncome = cashFlow.otherIncome {
            let mainIncomeViewModel = AmountCardItemViewModel(
                title: "Other income",
                amount: otherIncome,
                type: .income
            )
            
            items.append(mainIncomeViewModel)
        }
        
        return items
    }
}
