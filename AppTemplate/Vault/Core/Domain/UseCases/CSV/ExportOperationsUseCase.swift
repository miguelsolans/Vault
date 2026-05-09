//
//  ExportOperationsUseCase.swift
//  Vault
//
//  Created by Miguel Solans on 19/04/2026.
//

import Foundation

struct ExportOperationsRequest {
    let vaultID: UUID
    let csvConfiguration: CSVConfiguration

    init(
        vaultID: UUID,
        csvConfiguration: CSVConfiguration = CSVConfiguration()
    ) {
        self.vaultID = vaultID
        self.csvConfiguration = csvConfiguration
    }
}

struct ExportOperationsResponse {
    let csvContent: String
    let exportedCount: Int
    let suggestedFilename: String
}

final class ExportOperationsUseCase {

    private let operationRepository: OperationRepository
    private let vaultRepository: VaultRepository

    private let dateFormat = "d MMMM yyyy"
    private let localeIdentifier = "pt_PT"

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: localeIdentifier)
        return formatter
    }()

    init(
        operationRepository: OperationRepository,
        vaultRepository: VaultRepository
    ) {
        self.operationRepository = operationRepository
        self.vaultRepository = vaultRepository
    }

    func execute(_ request: ExportOperationsRequest) throws -> ExportOperationsResponse {

        // Validate vault exists
        guard let vault = try vaultRepository.get(by: request.vaultID) else {
            throw CSVExportError.vaultNotFound(request.vaultID)
        }

        // Fetch all operations for the vault
        let operations = try operationRepository.getAll(from: vault)

        guard !operations.isEmpty else {
            throw CSVExportError.noOperationsFound
        }

        // Convert operations to CSV rows
        let csvRows = try operations.map { operation in
            try convertOperationToCSVRow(operation)
        }

        // Define CSV header
        let header = [
            "Date",
            "Type",
            "Category",
            "Description",
            "Amount"
        ]

        // Generate CSV content
        let csvWriter = CSVWriter(configuration: request.csvConfiguration)
        let csvContent = try csvWriter.writeData(header: header, rows: csvRows)

        // Generate suggested filename
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        let suggestedFilename = "vault_\(vault.title ?? "export")_operations_\(dateString).csv"

        return ExportOperationsResponse(
            csvContent: csvContent,
            exportedCount: operations.count,
            suggestedFilename: suggestedFilename
        )
    }

    private func convertOperationToCSVRow(_ operation: Operation) throws -> [String: String] {
        var row: [String: String] = [:]

        // Date
        row["Date"] = dateFormatter.string(from: operation.date!)

        // Type
        let typeString: String
        switch operation.operationType {
        case .expense:
            typeString = "Expense"
        case .income:
            typeString = "Income"
        @unknown default:
            typeString = "Unknown"
        }
        row["Type"] = typeString

        // Category
        row["Category"] = operation.category?.name ?? "Unknown"

        // Description
        row["Description"] = operation.title ?? ""

        // Amount
        if let amount = currencyFormatter.string(from: NSNumber(value: operation.amount)) {
            row["Amount"] = amount
        } else {
            row["Amount"] = String(format: "%.2f", operation.amount)
        }

        return row
    }
}

// MARK: - Usage Example
/*
 // Example usage of ExportOperationsUseCase in a ViewModel:

 let vaultID = UUID(uuidString: "your-vault-id")!

 let request = ExportOperationsRequest(
     vaultID: vaultID,
     csvConfiguration: CSVConfiguration(separator: ";", hasHeader: true)
 )

 let useCase = ExportOperationsUseCase(
     operationRepository: OperationRepository(),
     vaultRepository: VaultRepository()
 )

 do {
     let response = try useCase.execute(request)

     // Show file picker to user with suggested filename
     showSaveFileDialog(
         suggestedFilename: response.suggestedFilename,
         fileContent: response.csvContent
     ) { selectedURL in
         // User selected a location, save the file
         do {
             try response.csvContent.write(to: selectedURL, atomically: true, encoding: .utf8)
             print("Successfully exported \(response.exportedCount) operations")
         } catch {
             print("Failed to save file: \(error.localizedDescription)")
         }
     }

 } catch {
     print("Export failed: \(error.localizedDescription)")
 }

 private func showSaveFileDialog(suggestedFilename: String, fileContent: String, completion: @escaping (URL) -> Void) {
     // Use UIDocumentPickerViewController or similar to let user choose save location
     // This would be implemented in your ViewController/ViewModel
 }
 */