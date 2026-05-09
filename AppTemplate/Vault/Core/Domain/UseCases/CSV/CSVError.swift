//
//  CSVError.swift
//  Vault
//
//  Created by Miguel Solans on 19/04/2026.
//

import Foundation

enum CSVImportError: LocalizedError {
    case invalidDate(String)
    case invalidAmount(String)
    case missingField(String)
    case invalidOperationType(String)
    case repositoryError(String)
    case fileAccessFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidDate(let value):
            return "Invalid date format: \(value)"
        case .invalidAmount(let value):
            return "Invalid amount format: \(value)"
        case .missingField(let field):
            return "Missing required field: \(field)"
        case .invalidOperationType(let type):
            return "Invalid operation type: \(type). Use 'expense' or 'income'"
        case .repositoryError(let message):
            return "Database error: \(message)"
        case .fileAccessFailed:
            return "Unable to access the CSV file"
        }
    }
}

enum CSVExportError: LocalizedError {
    case vaultNotFound(UUID)
    case noOperationsFound
    case fileWriteFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .vaultNotFound(let id):
            return "Vault with ID \(id.uuidString) not found"
        case .noOperationsFound:
            return "No operations found to export"
        case .fileWriteFailed(let message):
            return "Failed to write CSV file: \(message)"
        }
    }
}