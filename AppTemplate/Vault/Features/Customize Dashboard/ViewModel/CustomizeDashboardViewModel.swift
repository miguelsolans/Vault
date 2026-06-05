//
//  CustomizeDashboardViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 04/06/2026.
//

import UIKit
import CoreKit
import VaultCore

final class CustomizeDashboardViewModel: NSObject {
    
    private let vault: VaultDTO
    
    private let vaultDashboardUseCase: GetVaultDashboardUseCase
    
    private let updateWidgetUseCase: UpdateWidgetUseCase
    
    init(
        vault: VaultDTO,
        vaultDashboardUseCase: GetVaultDashboardUseCase,
        updateWidgetUseCase: UpdateWidgetUseCase
    ) {
        self.vault = vault
        self.vaultDashboardUseCase = vaultDashboardUseCase
        self.updateWidgetUseCase = updateWidgetUseCase
    }
    
    // MARK: - UI State
    
    public var title: String = "Customize Dashboard";
    
    public var subtitle: String = "";
    
    public var numberOfRows: Int { widgets.count }
    
    private var widgets: [CustomizeDashboardTableViewModel] = []
    
    // MARK: - Bindings
    
    public var updateUI: (() -> Void)?
    
    public var onSuccess: ((ViewModelFeedback) -> Void)?
    
    public var onError: ((ViewModelFeedback) -> Void)?
    
}

extension CustomizeDashboardViewModel {
    public func widget(at indexPath: IndexPath) -> CustomizeDashboardTableViewModel {
        return widgets[ indexPath.row ]
    }
}

extension CustomizeDashboardViewModel {
    func getData() {
        
        let request = GetVaultDashboardRequest(vaultID: vault.id)
        
        do {
            let response = try vaultDashboardUseCase.execute(request)
            
            makeWidgetsViewModel(from: response.dashboard)
        } catch {
            onError?(.showAlert(message: "There was an error fetching widgets. Try again later."))
        }
        
        updateUI?()
    }
    
    func updateVisibility(isVisible: Bool, at indexPath: IndexPath) {
        
        let widget = widget(at: indexPath)
        
        let request = UpdateWidgetRequest(
            widgetID: widget.id,
            isVisible: isVisible
        )
        
        do {
            _ = try updateWidgetUseCase.execute(request)
        } catch {
            getData()
            onError?(.showAlert(message: "There was an error editing the visibility of the widget. Try again later."))
        }
    }
}

extension CustomizeDashboardViewModel {
    
    private func makeWidgetsViewModel(from dashboard: DashboardDTO) {
        
        widgets = []
        
        for widget in dashboard.widgets {
            widgets.append(
                .init(
                    id: widget.id,
                    imageName: imageForWidget(widget),
                    title: titleForWidget(widget),
                    subtitle: descriptionForWidget(widget),
                    isToggleOn: widget.isVisible
                )
            )
        }
    }
    
    private func titleForWidget(_ widget: DashboardWidgetDTO) -> String {
        switch widget.type {
        case .totalIncomeAndSpending:
            return "Total income and spending"
        case .totalMainAndOtherIncome:
            return "Main and other income"
        case .pieChartSpendingCategories:
            return "Pie chart spending categories"
        case .pieChartIncomeCategories:
            return "Pie chart income categories"
        case .barChartSpendingCategories:
            return "Bar chart spending categories"
        case .barChartIncomeCategories:
            return "Bar chart income categories"
        case .keyMetrics:
            return "Key metrics"
        case .incomeBreakdown:
            return "Income breakdown"
        case .spendingBreakdown:
            return "Spending breakdown"
        case .unknown:
            return "Unknown"
        }
    }
    
    private func descriptionForWidget(_ widget: DashboardWidgetDTO) -> String? {
        switch widget.type {
        case .totalIncomeAndSpending:
            return "A card displaying total income and spent"
        case .totalMainAndOtherIncome:
            return "A card displaying main and other income"
        case .pieChartSpendingCategories:
            return "A pie chart with spending categories"
        case .pieChartIncomeCategories:
            return "A pie chart with income categories"
        case .barChartSpendingCategories:
            return "A bar chart with spending categories"
        case .barChartIncomeCategories:
            return "A bar chart with income categories"
        case .keyMetrics:
            return "A card with metrics such as average and saving efficiency"
        case .incomeBreakdown:
            return "A breakdown of all income categories"
        case .spendingBreakdown:
            return "A breakdown of all spending categories"
        case .unknown:
            return nil
        }
    }
    
    private func imageForWidget(_ widget: DashboardWidgetDTO) -> String? {
        switch widget.type {
        case .totalIncomeAndSpending:
            return "wallet.pass"
        case .totalMainAndOtherIncome:
            return "plus.circle"
        case .pieChartSpendingCategories:
            return "chart.pie"
        case .pieChartIncomeCategories:
            return "chart.pie"
        case .barChartSpendingCategories:
            return "chart.bar.xaxis.descending"
        case .barChartIncomeCategories:
            return "chart.bar.xaxis.descending"
        case .keyMetrics:
            return "percent"
        case .incomeBreakdown:
            return "list.bullet"
        case .spendingBreakdown:
            return "list.bullet"
        case .unknown:
            return nil
        }
    }
}
