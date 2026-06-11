//
//  L10n+Operations.swift
//  Vault
//
//  Created by Miguel Solans on 08/06/2026.
//

import Foundation

extension L10n.Operations {
    static let pageTitle = NSLocalizedString("common.general.operations", comment: "Operations page title")
    static let fromCamera = NSLocalizedString("operations.action.fromCamera", comment: "From camera action")
    static let expectingReimbursements = "Expecting %d reimbursement%@"
    static let emptyTitle = NSLocalizedString("operations.empty.title", comment: "Operations empty title")
    static let emptyMessage = NSLocalizedString("operations.empty.message", comment: "Operations empty message")
    static let errorFetchingOperations = NSLocalizedString("operations.error.fetchingOperations", comment: "Error fetching operations")
    static let errorDeletingOperation = NSLocalizedString("operations.error.deletingOperation", comment: "Error deleting operation")
    static let reimbursementCount = NSLocalizedString("operations.numberOfReimbursements", comment: "Number of reimbursements")
}
