//
//  OperationType.swift
//  Vault
//
//  Created by Miguel Solans on 08/06/2026.
//

import VaultCore

extension OperationType {
    public var localized: String {
        switch self {
        case .income:
            return L10n.Common.income
        case .expense:
            return L10n.Common.expense
        }
    }
}
