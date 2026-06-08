//
//  ReimbursementStatus+Localized.swift
//  Vault
//
//  Created by Miguel Solans on 08/06/2026.
//

import VaultCore

extension ReimbursementStatus {
    public var localized: String {
        switch self {
        case .expected:
            return L10n.Common.expected
        case .received:
            return L10n.Common.received
        case .cancelled:
            return L10n.Common.cancelled
        }
    }
}
