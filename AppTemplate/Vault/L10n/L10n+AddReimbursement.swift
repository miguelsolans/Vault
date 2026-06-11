//
//  L10n+AddReimbursement.swift
//  Vault
//
//  Created by Miguel Solans on 08/06/2026.
//

import Foundation

extension L10n.AddReimbursement {
    static let pageTitle = NSLocalizedString("common.general.addReimbursement", comment: "Add reimbursement page title")
    static let pageSubtitle = NSLocalizedString("reimbursement.add.page.subtitle", comment: "Add reimbursement page subtitle")
    static let maximumReimbursementTitle = NSLocalizedString("reimbursement.add.maximumTitle", comment: "Maximum reimbursement title")
    static let maximumReimbursementMessage = NSLocalizedString("reimbursement.add.maximumMessage", comment: "Maximum reimbursement message")
    static let status = NSLocalizedString("reimbursement.add.status", comment: "Status label")
    static let amount = NSLocalizedString("common.general.amount", comment: "Reimbursement amount label")
    static let enterAmount = NSLocalizedString("common.general.enterAmount", comment: "Enter amount placeholder")
    static let title = NSLocalizedString("reimbursement.add.title", comment: "Title label")
    static let enterTitle = NSLocalizedString("reimbursement.add.enterTitle", comment: "Enter title placeholder")
    static let depositVault = NSLocalizedString("reimbursement.add.depositVault", comment: "Deposit vault label")
    static let chooseDepositVault = NSLocalizedString("reimbursement.add.chooseDepositVault", comment: "Choose deposit vault placeholder")
    static let depositVaultFeedbackTitle = NSLocalizedString("reimbursement.add.depositVaultFeedback.title", comment: "Deposit vault feedback title")
    static let depositVaultFeedbackMessage = NSLocalizedString("reimbursement.add.depositVaultFeedback.message", comment: "Deposit vault feedback message")
    static let depositIncomeCategory = NSLocalizedString("reimbursement.add.depositIncomeCategory", comment: "Deposit income category label")
    static let chooseDepositCategory = NSLocalizedString("reimbursement.add.chooseDepositCategory", comment: "Choose deposit category placeholder")
    static let amountRequired = NSLocalizedString("common.general.amountRequired", comment: "Amount required validation")
    static let amountGreaterThanZero = NSLocalizedString("reimbursement.add.amountGreaterThanZero", comment: "Amount greater than zero validation")
    static let amountInferiorOrEqual = NSLocalizedString("reimbursement.add.amountInferiorOrEqual", comment: "Amount inferior or equal validation")
    static let depositVaultRequired = NSLocalizedString("reimbursement.add.depositVaultRequired", comment: "Deposit vault required validation")
    static let depositCategoryRequired = NSLocalizedString("reimbursement.add.depositCategoryRequired", comment: "Deposit category required validation")
    static let errorFetchingVaults = NSLocalizedString("reimbursement.add.error.fetchingVaults", comment: "Error fetching vaults")
    static let errorFetchingVaultCategories = NSLocalizedString("reimbursement.add.error.fetchingVaultCategories", comment: "Error fetching vault categories")
    static let errorSavingReimbursement = NSLocalizedString("reimbursement.add.error.savingReimbursement", comment: "Error saving reimbursement")
}
