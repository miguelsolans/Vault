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
    
    public var title: String = L10n.CustomizeDashboard.pageTitle;
    
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
            onError?(.showAlert(message: L10n.CustomizeDashboard.errorFetchingWidgets))
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
            onError?(.showAlert(message: L10n.CustomizeDashboard.errorUpdatingWidgetVisibility))
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
            return L10n.CustomizeDashboard.totalIncomeAndSpendingTitle
        case .totalMainAndOtherIncome:
            return L10n.CustomizeDashboard.mainAndOtherIncomeTitle
        case .pieChartSpendingCategories:
            return L10n.CustomizeDashboard.pieChartSpendingCategoriesTitle
        case .pieChartIncomeCategories:
            return L10n.CustomizeDashboard.pieChartIncomeCategoriesTitle
        case .barChartSpendingCategories:
            return L10n.CustomizeDashboard.barChartSpendingCategoriesTitle
        case .barChartIncomeCategories:
            return L10n.CustomizeDashboard.barChartIncomeCategoriesTitle
        case .keyMetrics:
            return L10n.CustomizeDashboard.keyMetricsTitle
        case .incomeBreakdown:
            return L10n.CustomizeDashboard.incomeBreakdownTitle
        case .spendingBreakdown:
            return L10n.CustomizeDashboard.spendingBreakdownTitle
        case .unknown:
            return L10n.CustomizeDashboard.unknownTitle
        }
    }
    
    private func descriptionForWidget(_ widget: DashboardWidgetDTO) -> String? {
        switch widget.type {
        case .totalIncomeAndSpending:
            return L10n.CustomizeDashboard.totalIncomeAndSpendingDescription
        case .totalMainAndOtherIncome:
            return L10n.CustomizeDashboard.totalMainAndOtherIncomeDescription
        case .pieChartSpendingCategories:
            return L10n.CustomizeDashboard.pieChartSpendingCategoriesDescription
        case .pieChartIncomeCategories:
            return L10n.CustomizeDashboard.pieChartIncomeCategoriesDescription
        case .barChartSpendingCategories:
            return L10n.CustomizeDashboard.barChartSpendingCategoriesDescription
        case .barChartIncomeCategories:
            return L10n.CustomizeDashboard.barChartIncomeCategoriesDescription
        case .keyMetrics:
            return L10n.CustomizeDashboard.keyMetricsDescription
        case .incomeBreakdown:
            return L10n.CustomizeDashboard.incomeBreakdownDescription
        case .spendingBreakdown:
            return L10n.CustomizeDashboard.spendingBreakdownDescription
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
