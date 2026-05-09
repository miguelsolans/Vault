//
//  ImportOperationsUseCase.swift
//  Vault
//
//  Created by Miguel Solans on 19/04/2026.
//

import Foundation

struct ImportOperationsRequest {
    let vaultID: UUID
    let fileURL: URL
    let fieldMapping: ImportFieldMapping
    let csvConfiguration: CSVConfiguration
    
    init(
        vaultID: UUID,
        fileURL: URL,
        fieldMapping: ImportFieldMapping,
        csvConfiguration: CSVConfiguration = CSVConfiguration()
    ) {
        self.vaultID = vaultID
        self.fileURL = fileURL
        self.fieldMapping = fieldMapping
        self.csvConfiguration = csvConfiguration
    }
}

struct ImportOperationsResponse {
    let successCount: Int
    let failureCount: Int
    let errors: [CSVImportError]
}

final class ImportOperationsUseCase {
    
    private let operationRepository: OperationRepository
    private let categoryRepository: CategoryRepository
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
        categoryRepository: CategoryRepository,
        vaultRepository: VaultRepository
    ) {
        self.operationRepository = operationRepository
        self.categoryRepository = categoryRepository
        self.vaultRepository = vaultRepository
    }
    
    func execute(_ request: ImportOperationsRequest) throws -> ImportOperationsResponse {
        
        // Validate vault exists
        guard let vault = try vaultRepository.get(by: request.vaultID) else {
            throw VaultError.vaultNotFound(request.vaultID)
        }
        
        // Validate required field mappings
        guard request.fieldMapping.date != nil else {
            throw CSVImportError.missingField("Date field mapping is required")
        }
        
        guard request.fieldMapping.amount != nil else {
            throw CSVImportError.missingField("Amount field mapping is required")
        }
        
        guard request.fieldMapping.description != nil else {
            throw CSVImportError.missingField("Description field mapping is required")
        }
        
        // Parse CSV file
        let csvReader = CSVReader(fileURL: request.fileURL, configuration: request.csvConfiguration)
        let (_, rows) = try csvReader.readData()
        
        var errors: [CSVImportError] = []
        var successCount = 0
        
        for row in rows {
            if let error = processRow(row, vault: vault, mapping: request.fieldMapping) {
                errors.append(error)
            } else {
                successCount += 1
            }
        }
        
        return ImportOperationsResponse(
            successCount: successCount,
            failureCount: errors.count,
            errors: errors
        )
    }
    
    private func processRow(
        _ row: [String: String],
        vault: Vault,
        mapping: ImportFieldMapping
    ) -> CSVImportError? {
        
        // Extract and validate date
        guard let dateKey = mapping.date,
              let dateString = row[dateKey], !dateString.isEmpty else {
            return .missingField(mapping.date ?? "date")
        }
        
        guard let date = dateFormatter.date(from: dateString) else {
            return .invalidDate(dateString)
        }
        
        // Extract and validate amount
        guard let amountKey = mapping.amount,
              let amountString = row[amountKey], !amountString.isEmpty else {
            return .missingField(mapping.amount ?? "amount")
        }
        
        guard let amount = currencyFormatter.number(from: amountString) else {
            return .invalidAmount(amountString)
        }
        
        // Extract and validate description
        guard let descriptionKey = mapping.description,
              let title = row[descriptionKey], !title.isEmpty else {
            return .missingField(mapping.description ?? "description")
        }
        
        // Determine operation type
        let operationType: OperationType
        if let typeKey = mapping.operation,
           let typeString = row[typeKey]?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            
            switch typeString {
            case "expense", "despesa":
                operationType = .expense
            case "income", "receita":
                operationType = .income
            default:
                return .invalidOperationType(typeString)
            }
        } else {
            // Default to expense if not specified
            operationType = .expense
        }
        
        // Determine category
        let categoryName: String
        if let categoryKey = mapping.category,
           let value = row[categoryKey], !value.isEmpty {
            categoryName = value
        } else {
            categoryName = "Others"
        }
        
        // Create or fetch category and add operation
        do {
            let category = try categoryRepository.findOrCreate(
                named: categoryName,
                type: operationType,
                in: vault
            )
            
            try _ = operationRepository.add(
                title: title,
                subtitle: title,
                date: date,
                type: operationType,
                amount: amount.doubleValue,
                vault: vault,
                category: category
            )
            
            return nil // Success
            
        } catch {
            return .repositoryError(error.localizedDescription)
        }
    }
}