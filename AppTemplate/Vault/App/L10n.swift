//  L10n.swift
//  Vault
//
//  Created by Miguel Solans on 06/06/2026.
//

import Foundation

public enum L10n {
    private static func tr(_ key: String, comment: String = "") -> String {
        NSLocalizedString(key, comment: comment)
    }

    enum Common {
        static let vault = tr("common.general.vault", comment: "Vault label")
        static let error = tr("common.general.error", comment: "Error title")
        static let success = tr("common.general.success", comment: "Success title")
        static let noData = tr("common.general.noData", comment: "No data label")
        static let errorFetchingData = tr("common.general.errorFetchingData", comment: "Error fetching data message")
        static let ok = tr("common.general.ok", comment: "Ok button title")
        static let delete = tr("common.general.delete", comment: "Delete action")
        static let edit = tr("common.general.edit", comment: "Edit action")
        static let save = tr("common.general.save", comment: "Save action")
        static let expense = tr("common.general.expense", comment: "Expense label")
        static let income = tr("common.general.income", comment: "Income label")
        static let optional = tr("common.general.optional", comment: "Optional label")
        static let cancel = tr("common.general.cancel", comment: "Cancel action")
        static let received = tr("common.general.received", comment: "Received status")
        static let expected = tr("common.general.expected", comment: "Expected status")
        static let cancelled = tr("common.general.cancelled", comment: "Cancelled status")
        static let disable = tr("common.general.disable", comment: "Disable action")
    }

    enum Onboarding {
        static let offlineTitle = tr("onboarding.offline.title", comment: "Offline title")
        static let offlineDescription = tr("onboarding.offline.description", comment: "Offline description")
        static let trackSpendingTitle = tr("onboarding.trackSpending.title", comment: "Track spending title")
        static let trackSpendingDescription = tr("onboarding.trackSpending.description", comment: "Track spending description")
        static let personalizeCategoriesTitle = tr("onboarding.personalizeCategories.title", comment: "Personalize categories title")
        static let personalizeCategoriesDescription = tr("onboarding.personalizeCategories.description", comment: "Personalize categories description")
        static let trackReimbursementsTitle = tr("onboarding.trackReimbursements.title", comment: "Track reimbursements title")
        static let trackReimbursementsDescription = tr("onboarding.trackReimbursements.description", comment: "Track reimbursements description")
        static let multipleVaultsTitle = tr("onboarding.multipleVaults.title", comment: "Multiple Vaults title")
        static let multipleVaultsDescription = tr("onboarding.multipleVaults.description", comment: "Multiple Vaults description")
        static let saveSmarterTitle = tr("onboarding.saveSmarter.title", comment: "Save smarter title")
        static let saveSmarterDescription = tr("onboarding.saveSmarter.description", comment: "Save smarter description")
        static let ctaTitle = tr("onboarding.cta.title", comment: "Create Vault CTA title")
    }

    enum Vaults {
        static let pageTitle = tr("vaults.page.title", comment: "Vaults page title")
        static let pageSubtitle = tr("vaults.page.subtitle", comment: "Vaults page subtitle")
        static let favorite = tr("vaults.action.favorite", comment: "Favorite action")
        static let export = tr("vaults.action.export", comment: "Export action")
        static let errorFetchingVaults = tr("vaults.error.fetchingVaults", comment: "Error fetching vaults")
        static let errorDeletingVault = tr("vaults.error.deletingVault", comment: "Error deleting vault")
        static let errorExportingVault = tr("vaults.error.exportingVault", comment: "Error exporting vault")
    }

    enum CreateVault {
        static let pageTitle = tr("vault.create.page.title", comment: "Create vault page title")
        static let pageSubtitle = tr("vault.create.page.subtitle", comment: "Create vault page subtitle")
        static let name = tr("vault.create.field.name", comment: "Vault name field")
        static let enterName = tr("vault.create.field.enterName", comment: "Enter vault name placeholder")
        static let initialAmount = tr("vault.create.field.initialAmount", comment: "Initial amount field")
        static let setupInitialAmount = tr("vault.create.field.setupInitialAmount", comment: "Setup initial amount field")
        static let enterInitialAmount = tr("vault.create.field.enterInitialAmount", comment: "Enter initial amount placeholder")
        static let importOperations = tr("vault.create.field.importOperations", comment: "Import operations field")
        static let importFromCsv = tr("vault.create.field.importFromCsv", comment: "Import from CSV placeholder")
        static let csvFile = tr("vault.create.field.csvFile", comment: "CSV file field")
        static let nameRequired = tr("vault.create.validation.nameRequired", comment: "Name required validation")
        static let initialAmountRequired = tr("vault.create.validation.initialAmountRequired", comment: "Initial amount required validation")
        static let fileRequired = tr("vault.create.validation.fileRequired", comment: "File required validation")
        static let vaultWithNameAlreadyExists = tr("vault.create.error.nameAlreadyExists", comment: "Vault name already exists error")
        static let errorCreatingVault = tr("vault.create.error.creatingVault", comment: "Error creating vault")
    }

    enum EditVault {
        static let pageTitle = tr("vault.edit.page.title", comment: "Edit vault page title")
        static let vaultWithNameAlreadyExists = tr("vault.edit.error.nameAlreadyExists", comment: "Vault name already exists error")
        static let errorUpdatingVault = tr("vault.edit.error.updatingVault", comment: "Error updating vault")
    }

    enum Overview {
        static let pageTitle = tr("dashboard.overview.page.title", comment: "Overview page title")
        static let customizeDashboard = tr("dashboard.overview.customizeDashboard", comment: "Customize dashboard action")
        static let yearly = tr("dashboard.overview.mode.yearly", comment: "Yearly label")
        static let monthly = tr("dashboard.overview.mode.monthly", comment: "Monthly label")
        static let emptyDataDescription = tr("dashboard.overview.emptyData.description", comment: "Empty data description")
        static let emptyWidgetTitle = tr("dashboard.overview.emptyWidget.title", comment: "Empty widget title")
        static let emptyWidgetDescription = tr("dashboard.overview.emptyWidget.description", comment: "Empty widget description")
        static let errorDashboardConfiguration = tr("dashboard.overview.error.fetchingConfiguration", comment: "Error fetching dashboard configuration")
        static let yourIncome = tr("dashboard.overview.yourIncome", comment: "Your income label")
        static let keyMetrics = tr("dashboard.overview.keyMetrics", comment: "Key metrics label")
        static let averageIncome = tr("dashboard.overview.averageIncome", comment: "Average income label")
        static let averageSpent = tr("dashboard.overview.averageSpent", comment: "Average spent label")
        static let totalSaved = tr("dashboard.overview.totalSaved", comment: "Total saved label")
        static let savingEfficiency = tr("dashboard.overview.savingEfficiency", comment: "Saving efficiency label")
        static let totalIncome = tr("dashboard.overview.totalIncome", comment: "Total income label")
        static let totalExpenses = tr("dashboard.overview.totalExpenses", comment: "Total expenses label")
        static let mainIncome = tr("dashboard.overview.mainIncome", comment: "Main income label")
        static let otherIncome = tr("dashboard.overview.otherIncome", comment: "Other income label")
        static let yourExpenses = tr("dashboard.overview.yourExpenses", comment: "Your expenses label")
        static let spendingBreakdown = tr("dashboard.overview.spendingBreakdown", comment: "Spending breakdown label")
        static let incomeBreakdown = tr("dashboard.overview.incomeBreakdown", comment: "Income breakdown label")
        static let pendingReimbursementsTitle = tr("dashboard.overview.pendingReimbursements.title", comment: "Pending reimbursements title")
        static let pendingReimbursementsBody = tr("dashboard.overview.pendingReimbursements.body", comment: "Pending reimbursements body")
        static let spendingDistribution = tr("dashboard.overview.spendingDistribution", comment: "Spending distribution label")
        static let incomeDistribution = tr("dashboard.overview.incomeDistribution", comment: "Income distribution label")
    }

    enum CustomizeDashboard {
        static let pageTitle = tr("dashboard.customize.page.title", comment: "Customize dashboard page title")
        static let totalIncomeAndSpendingTitle = tr("dashboard.customize.totalIncomeAndSpending.title", comment: "Total income and spending title")
        static let totalIncomeAndSpendingDescription = tr("dashboard.customize.totalIncomeAndSpending.description", comment: "Total income and spending description")
        static let mainAndOtherIncomeTitle = tr("dashboard.customize.mainAndOtherIncome.title", comment: "Main and other income title")
        static let totalMainAndOtherIncomeDescription = tr("dashboard.customize.mainAndOtherIncome.description", comment: "Main and other income description")
        static let pieChartSpendingCategoriesTitle = tr("dashboard.customize.pieChartSpendingCategories.title", comment: "Pie chart spending categories title")
        static let pieChartSpendingCategoriesDescription = tr("dashboard.customize.pieChartSpendingCategories.description", comment: "Pie chart spending categories description")
        static let pieChartIncomeCategoriesTitle = tr("dashboard.customize.pieChartIncomeCategories.title", comment: "Pie chart income categories title")
        static let pieChartIncomeCategoriesDescription = tr("dashboard.customize.pieChartIncomeCategories.description", comment: "Pie chart income categories description")
        static let barChartSpendingCategoriesTitle = tr("dashboard.customize.barChartSpendingCategories.title", comment: "Bar chart spending categories title")
        static let barChartSpendingCategoriesDescription = tr("dashboard.customize.barChartSpendingCategories.description", comment: "Bar chart spending categories description")
        static let barChartIncomeCategoriesTitle = tr("dashboard.customize.barChartIncomeCategories.title", comment: "Bar chart income categories title")
        static let barChartIncomeCategoriesDescription = tr("dashboard.customize.barChartIncomeCategories.description", comment: "Bar chart income categories description")
        static let keyMetricsTitle = tr("dashboard.customize.keyMetrics.title", comment: "Key metrics title")
        static let keyMetricsDescription = tr("dashboard.customize.keyMetrics.description", comment: "Key metrics description")
        static let incomeBreakdownTitle = tr("dashboard.customize.incomeBreakdown.title", comment: "Income breakdown title")
        static let incomeBreakdownDescription = tr("dashboard.customize.incomeBreakdown.description", comment: "Income breakdown description")
        static let spendingBreakdownTitle = tr("dashboard.customize.spendingBreakdown.title", comment: "Spending breakdown title")
        static let spendingBreakdownDescription = tr("dashboard.customize.spendingBreakdown.description", comment: "Spending breakdown description")
        static let unknownTitle = tr("dashboard.customize.unknownTitle", comment: "Unknown title")
        static let errorFetchingWidgets = tr("dashboard.customize.error.fetchingWidgets", comment: "Error fetching widgets")
        static let errorUpdatingWidgetVisibility = tr("dashboard.customize.error.updatingWidgetVisibility", comment: "Error updating widget visibility")
    }

    enum Breakdown {
        static let incomePageTitle = tr("dashboard.breakdown.income.page.title", comment: "Income breakdown page title")
        static let spendingPageTitle = tr("dashboard.breakdown.spending.page.title", comment: "Spending breakdown page title")
        static let breakdown = tr("dashboard.breakdown.title", comment: "Breakdown title")
        static let mainIncome = tr("dashboard.breakdown.mainIncome", comment: "Main income label")
        static let otherIncome = tr("dashboard.breakdown.otherIncome", comment: "Other income label")
    }

    enum Feedback {
        static let pageTitle = tr("feedback.page.title", comment: "Feedback page title")
        static let subtitle = tr("feedback.page.subtitle", comment: "Feedback page subtitle")
    }

    enum Operations {
        static let pageTitle = tr("operations.page.title", comment: "Operations page title")
        static let fromCamera = tr("operations.action.fromCamera", comment: "From camera action")
        static let emptyTitle = tr("operations.empty.title", comment: "Operations empty title")
        static let emptyMessage = tr("operations.empty.message", comment: "Operations empty message")
        static let errorFetchingOperations = tr("operations.error.fetchingOperations", comment: "Error fetching operations")
        static let errorDeletingOperation = tr("operations.error.deletingOperation", comment: "Error deleting operation")
    }

    enum OperationDetail {
        static let pageTitle = tr("operation.detail.page.title", comment: "Operation detail page title")
        static let pageSubtitle = tr("operation.detail.page.subtitle", comment: "Operation detail page subtitle")
        static let type = tr("operation.detail.type", comment: "Operation type label")
        static let notes = tr("operation.detail.notes", comment: "Notes label")
        static let operationAmount = tr("operation.detail.amount", comment: "Operation amount label")
        static let totalReimbursed = tr("operation.detail.totalReimbursed", comment: "Total reimbursed label")
        static let remaining = tr("operation.detail.remaining", comment: "Remaining label")
        static let operationDetail = tr("operation.detail.operationDetail", comment: "Operation detail label")
        static let reimbursements = tr("operation.detail.reimbursements", comment: "Reimbursements label")
        static let summary = tr("operation.detail.summary", comment: "Summary label")
        static let errorUpdatingReimbursementStatus = tr("operation.detail.error.updatingReimbursementStatus", comment: "Error updating reimbursement status")
        static let errorDeletingOperation = tr("operation.detail.error.deletingOperation", comment: "Error deleting operation")
    }

    enum AddOperation {
        static let pageTitle = tr("operation.add.page.title", comment: "Add operation page title")
        static let reviewDataTitle = tr("operation.add.review.title", comment: "Review data title")
        static let reviewDataMessage = tr("operation.add.review.message", comment: "Review data message")
        static let type = tr("operation.add.type", comment: "Operation type label")
        static let category = tr("operation.add.category", comment: "Category label")
        static let amount = tr("operation.add.amount", comment: "Amount label")
        static let enterAmount = tr("operation.add.enterAmount", comment: "Enter amount placeholder")
        static let description = tr("operation.add.description", comment: "Description label")
        static let enterDescription = tr("operation.add.enterDescription", comment: "Enter description placeholder")
        static let date = tr("operation.add.date", comment: "Date label")
        static let reimbursement = tr("operation.add.reimbursement", comment: "Reimbursement label")
        static let isSplitBill = tr("operation.add.isSplitBill", comment: "Split bill label")
        static let categoryRequired = tr("operation.add.categoryRequired", comment: "Category required validation")
        static let amountRequired = tr("operation.add.amountRequired", comment: "Amount required validation")
        static let amountInvalid = tr("operation.add.amountInvalid", comment: "Amount invalid validation")
        static let descriptionRequired = tr("operation.add.descriptionRequired", comment: "Description required validation")
        static let removeReimbursementToEditAmount = tr("operation.add.removeReimbursementToEditAmount", comment: "Remove reimbursement to edit amount message")
        static let addReimbursement = tr("operation.add.addReimbursement", comment: "Add reimbursement action")
        static let errorFetchingCategories = tr("operation.add.error.fetchingCategories", comment: "Error fetching categories")
        static let errorUpdatingReimbursementStatus = tr("operation.add.error.updatingReimbursementStatus", comment: "Error updating reimbursement status")
        static let errorCreatingOperation = tr("operation.add.error.creatingOperation", comment: "Error creating operation")
    }

    enum EditOperation {
        static let pageTitle = tr("operation.edit.page.title", comment: "Edit operation page title")
        static let errorUpdatingOperation = tr("operation.edit.error.updatingOperation", comment: "Error updating operation")
        static let errorDeletingReimbursement = tr("operation.edit.error.deletingReimbursement", comment: "Error deleting reimbursement")
    }

    enum AddReimbursement {
        static let pageTitle = tr("reimbursement.add.page.title", comment: "Add reimbursement page title")
        static let pageSubtitle = tr("reimbursement.add.page.subtitle", comment: "Add reimbursement page subtitle")
        static let maximumReimbursementTitle = tr("reimbursement.add.maximumTitle", comment: "Maximum reimbursement title")
        static let maximumReimbursementMessage = tr("reimbursement.add.maximumMessage", comment: "Maximum reimbursement message")
        static let status = tr("reimbursement.add.status", comment: "Status label")
        static let amount = tr("reimbursement.add.amount", comment: "Reimbursement amount label")
        static let enterAmount = tr("reimbursement.add.enterAmount", comment: "Enter amount placeholder")
        static let title = tr("reimbursement.add.title", comment: "Title label")
        static let enterTitle = tr("reimbursement.add.enterTitle", comment: "Enter title placeholder")
        static let depositVault = tr("reimbursement.add.depositVault", comment: "Deposit vault label")
        static let chooseDepositVault = tr("reimbursement.add.chooseDepositVault", comment: "Choose deposit vault placeholder")
        static let depositVaultFeedbackTitle = tr("reimbursement.add.depositVaultFeedback.title", comment: "Deposit vault feedback title")
        static let depositVaultFeedbackMessage = tr("reimbursement.add.depositVaultFeedback.message", comment: "Deposit vault feedback message")
        static let depositIncomeCategory = tr("reimbursement.add.depositIncomeCategory", comment: "Deposit income category label")
        static let chooseDepositCategory = tr("reimbursement.add.chooseDepositCategory", comment: "Choose deposit category placeholder")
        static let amountRequired = tr("reimbursement.add.amountRequired", comment: "Amount required validation")
        static let amountGreaterThanZero = tr("reimbursement.add.amountGreaterThanZero", comment: "Amount greater than zero validation")
        static let amountInferiorOrEqual = tr("reimbursement.add.amountInferiorOrEqual", comment: "Amount inferior or equal validation")
        static let depositVaultRequired = tr("reimbursement.add.depositVaultRequired", comment: "Deposit vault required validation")
        static let depositCategoryRequired = tr("reimbursement.add.depositCategoryRequired", comment: "Deposit category required validation")
        static let errorFetchingVaults = tr("reimbursement.add.error.fetchingVaults", comment: "Error fetching vaults")
        static let errorFetchingVaultCategories = tr("reimbursement.add.error.fetchingVaultCategories", comment: "Error fetching vault categories")
        static let errorSavingReimbursement = tr("reimbursement.add.error.savingReimbursement", comment: "Error saving reimbursement")
    }

    enum EditReimbursement {
        static let pageTitle = tr("reimbursement.edit.page.title", comment: "Edit reimbursement page title")
        static let pageSubtitle = tr("reimbursement.edit.page.subtitle", comment: "Edit reimbursement page subtitle")
    }

    enum OCR {
        static let pageTitle = tr("ocr.page.title", comment: "OCR page title")
        static let pageSubtitle = tr("ocr.page.subtitle", comment: "OCR page subtitle")
    }

    enum Categories {
        static let pageTitle = tr("categories.page.title", comment: "Categories page title")
        static let ascending = tr("categories.sort.ascending", comment: "Ascending sort option")
        static let descending = tr("categories.sort.descending", comment: "Descending sort option")
        static let type = tr("categories.sort.type", comment: "Type sort option")
        static let numberOfOperations = tr("categories.numberOfOperations", comment: "Number of operations string")
        static let errorFetchingCategories = tr("categories.error.fetchingCategories", comment: "Error fetching categories")
        static let errorDeletingCategory = tr("categories.error.deletingCategory", comment: "Error deleting category")
        static let emptyTitle = tr("categories.empty.title", comment: "Categories empty title")
        static let emptyDescription = tr("categories.empty.description", comment: "Categories empty description")
    }

    enum AddCategory {
        static let pageTitle = tr("category.add.page.title", comment: "Add category page title")
        static let type = tr("category.add.type", comment: "Category type label")
        static let emoji = tr("category.add.emoji", comment: "Category emoji label")
        static let enterEmoji = tr("category.add.enterEmoji", comment: "Enter emoji placeholder")
        static let categoryName = tr("category.add.name", comment: "Category name label")
        static let enterCategoryName = tr("category.add.enterName", comment: "Enter category name placeholder")
        static let color = tr("category.add.color", comment: "Category color label")
        static let categoryColor = tr("category.add.colorDescription", comment: "Category color description")
        static let plotting = tr("category.add.plotting", comment: "Plotting label")
        static let showInPlot = tr("category.add.showInPlot", comment: "Show in plot label")
        static let mainIncome = tr("category.add.mainIncome", comment: "Main income label")
        static let isMainSourceOfIncome = tr("category.add.isMainSourceOfIncome", comment: "Is main source of income label")
        static let categoryNameRequired = tr("category.add.validation.nameRequired", comment: "Category name required validation")
        static let errorAddingCategory = tr("category.add.error.addingCategory", comment: "Error adding category")
        static let errorCategoryAlreadyExists = tr("category.add.error.alreadyExists", comment: "Category already exists error")
    }

    enum EditCategory {
        static let pageTitle = tr("category.edit.page.title", comment: "Edit category page title")
        static let errorUpdatingCategory = tr("category.edit.error.updatingCategory", comment: "Error updating category")
        static let errorCategoryAlreadyExists = tr("category.edit.error.alreadyExists", comment: "Category already exists error")
    }

    enum CategoryDetail {
        static let pageTitle = tr("category.detail.page.title", comment: "Category detail page title")
        static let pageSubtitle = tr("category.detail.page.subtitle", comment: "Category detail page subtitle")
        static let type = tr("category.detail.type", comment: "Category detail type label")
        static let notes = tr("category.detail.notes", comment: "Category detail notes label")
        static let operationsCount = tr("category.detail.operationsCount", comment: "Operations count label")
        static let errorDeletingCategory = tr("category.detail.error.deletingCategory", comment: "Error deleting category")
    }

    enum Settings {
        static let pageTitle = tr("settings.page.title", comment: "Settings page title")
        static let pageSubtitle = tr("settings.page.subtitle", comment: "Settings page subtitle")
        static let vaultsOptionTitle = tr("settings.settings.vaultsOption.title", comment: "Vaults option title")
        static let vaultsOptionDescription = tr("settings.settings.vaultsOption.description", comment: "Vaults option description")
        static let securityOptionTitle = tr("settings.settings.securityOption.title", comment: "Security option title")
        static let securityOptionDescription = tr("settings.settings.securityOption.description", comment: "Security option description")
        static let backupOptionTitle = tr("settings.settings.backupOption.title", comment: "Backup option title")
        static let backupOptionDescription = tr("settings.settings.backupOption.description", comment: "Backup option description")
        static let aboutOptionTitle = tr("settings.settings.aboutOption.title", comment: "About option title")
        static let aboutOptionDescription = tr("settings.settings.aboutOption.description", comment: "About option description")
        static let deleteInformation = tr("settings.settings.deleteInformation", comment: "Delete information label")
        static let deleteInformationDisclaimer = tr("settings.settings.deleteInformationDisclaimer", comment: "Delete information disclaimer")
        static let errorDeletingData = tr("settings.settings.error.deletingData", comment: "Error deleting data")
    }

    enum Security {
        static let pageTitle = tr("security.page.title", comment: "Security page title")
        static let pageSubtitle = tr("security.page.subtitle", comment: "Security page subtitle")
        static let disablePin = tr("security.disablePin", comment: "Disable PIN label")
        static let disablePinMessage = tr("security.disablePinMessage", comment: "Disable PIN message")
        static let pinOptionTitle = tr("security.pinOption.title", comment: "PIN option title")
        static let pinOptionDescription = tr("security.pinOption.description", comment: "PIN option description")
        static let biometricOptionTitle = tr("security.biometricOption.title", comment: "Biometric option title")
        static let biometricOptionDescription = tr("security.biometricOption.description", comment: "Biometric option description")
        static let options = tr("security.options", comment: "Options label")
        static let autoLockOptionTitle = tr("security.autoLockOption.title", comment: "Auto-lock option title")
        static let immediately = tr("security.immediately", comment: "Immediately label")
        static let never = tr("security.never", comment: "Never label")
        static let requiresAuthenticationOptionTitle = tr("security.requiresAuthenticationOption.title", comment: "Requires authentication option title")
        static let requiresAuthenticationOptionDescription = tr("security.requiresAuthenticationOption.description", comment: "Requires authentication option description")
        static let authentication = tr("security.authentication", comment: "Authentication label")
        static let option = tr("security.option", comment: "Option label")
    }

    enum CreatePIN {
        static let pageTitle = tr("security.pin.create.page.title", comment: "Create PIN page title")
        static let numberOfDigits = tr("security.pin.create.numberOfDigits", comment: "PIN digit entry prompt")
    }

    enum About {
        static let pageTitle = tr("about.page.title", comment: "About page title")
        static let pageSubtitle = tr("about.page.subtitle", comment: "About page subtitle")
        static let privacyOptionTitle = tr("about.privacyOption.title", comment: "Privacy option title")
        static let privacyOptionDescription = tr("about.privacyOption.description", comment: "Privacy option description")
        static let dashboardOptionTitle = tr("about.dashboardOption.title", comment: "Dashboard option title")
        static let dashboardOptionDescription = tr("about.dashboardOption.description", comment: "Dashboard option description")
        static let vaultsOptionTitle = tr("about.vaultsOption.title", comment: "Vaults option title")
        static let vaultsOptionDescription = tr("about.vaultsOption.description", comment: "Vaults option description")
        static let categoriesOptionTitle = tr("about.categoriesOption.title", comment: "Categories option title")
        static let categoriesOptionDescription = tr("about.categoriesOption.description", comment: "Categories option description")
        static let operationsOptionTitle = tr("about.operationsOption.title", comment: "Operations option title")
        static let operationsOptionDescription = tr("about.operationsOption.description", comment: "Operations option description")
        static let versionOptionTitle = tr("about.versionOption.title", comment: "Version option title")
        static let general = tr("about.general", comment: "General section title")
        static let features = tr("about.features", comment: "Features section title")
        static let info = tr("about.info", comment: "Info section title")
        static let pageFooter = tr("about.pageFooter", comment: "About page footer")
    }

    enum Chat {
        static let pageTitle = tr("chat.page.title", comment: "Chat page title")
        static let pageSubtitle = tr("chat.page.subtitle", comment: "Chat page subtitle")
        static let firstMessage = tr("chat.firstMessage", comment: "Chat first assistant message")
        static let askVault = tr("chat.askVault", comment: "Ask Vault placeholder")
        static let send = tr("chat.send", comment: "Send action")
    }

    enum Tab {
        static let overview = tr("tab.overview", comment: "Overview tab")
        static let operations = tr("tab.operations", comment: "Operations tab")
        static let categories = tr("tab.categories", comment: "Categories tab")
        static let settings = tr("tab.settings", comment: "Settings tab")
        static let demo = tr("tab.demo", comment: "Demo tab")
    }
}
