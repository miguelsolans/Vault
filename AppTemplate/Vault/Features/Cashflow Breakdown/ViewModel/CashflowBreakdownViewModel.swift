//
//  CashflowBreakdownViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 08/05/2026.
//

import UIKit
import VaultCore


final class CashflowBreakdownViewModel: NSObject {

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
    
    public var subtitle: String? = nil
    
    private(set) var amountHeaderViewModel: AmountStatusHeaderViewModel?
    
    private(set) var plotViewModel: ChartViewModel?
    
    private(set) var categoriesViewModel: AmountCardSectionViewModel?
    
    // MARK: - Bindings
    
    public var updateUI: (() -> Void)?
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
                response.dashboardMetrics.cashFlow.income :
                response.dashboardMetrics.netSpending.netExpenses
            
            let percentage = filter.type == .income ?
                response.dashboardMetrics.cashFlow.incomeChangeFromPreviousMonth :
                response.dashboardMetrics.cashFlow.expensesChangeFromPreviousMonth
            
            let items = filter.type == .income ?
                response.dashboardMetrics.categories.income :
                response.dashboardMetrics.categories.netExpenses
            
            let average = filter.type == .income ?
                response.dashboardMetrics.cashFlow.averageIncome :
                response.dashboardMetrics.cashFlow.averageExpense
            
            amountHeaderViewModel = AmountStatusHeaderViewModel(
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
            
        } catch {
            // TODO: Present error?
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
}
