//
//  L10n+AddOperation.swift
//  Vault
//
//  Created by Miguel Solans on 08/06/2026.
//

import Foundation

extension L10n.AddOperation {
    static let pageTitle = NSLocalizedString("operation.add.page.title", comment: "Add operation page title")
    static let reviewDataTitle = NSLocalizedString("operation.add.review.title", comment: "Review data title")
    static let reviewDataMessage = NSLocalizedString("operation.add.review.message", comment: "Review data message")
    static let type = NSLocalizedString("common.general.type", comment: "Operation type label")
    static let category = NSLocalizedString("common.general.category", comment: "Category label")
    static let amount = NSLocalizedString("common.general.enterAmount", comment: "Amount label")
    static let enterAmount = NSLocalizedString("common.general.enterAmount", comment: "Enter amount placeholder")
    static let description = NSLocalizedString("operation.add.description", comment: "Description label")
    static let enterDescription = NSLocalizedString("operation.add.enterDescription", comment: "Enter description placeholder")
    static let date = NSLocalizedString("operation.add.date", comment: "Date label")
    static let reimbursement = NSLocalizedString("operation.add.reimbursement", comment: "Reimbursement label")
    static let isSplitBill = NSLocalizedString("operation.add.isSplitBill", comment: "Split bill label")
    static let categoryRequired = NSLocalizedString("operation.add.categoryRequired", comment: "Category required validation")
    static let amountRequired = NSLocalizedString("common.general.amountRequired", comment: "Amount required validation")
    static let amountInvalid = NSLocalizedString("operation.add.amountInvalid", comment: "Amount invalid validation")
    static let descriptionRequired = NSLocalizedString("operation.add.descriptionRequired", comment: "Description required validation")
    static let removeReimbursementToEditAmount = NSLocalizedString("operation.add.removeReimbursementToEditAmount", comment: "Remove reimbursement to edit amount message")
    static let addReimbursement = NSLocalizedString("common.general.addReimbursement", comment: "Add reimbursement action")
    static let errorFetchingCategories = NSLocalizedString("operation.add.error.fetchingCategories", comment: "Error fetching categories")
    static let errorUpdatingReimbursementStatus = NSLocalizedString("operation.add.error.updatingReimbursementStatus", comment: "Error updating reimbursement status")
    static let errorCreatingOperation = NSLocalizedString("operation.add.error.creatingOperation", comment: "Error creating operation")
}
