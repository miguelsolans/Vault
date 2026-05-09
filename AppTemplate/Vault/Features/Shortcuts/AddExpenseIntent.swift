//
//  AddExpenseIntent.swift
//  Vault
//
//  Created by Miguel Solans on 20/04/2026.
//

import AppIntents
import VaultCore

// MARK: - Expense
struct CategoryExpenseIntentEntity: AppEntity, Identifiable{
    
    var id: UUID
    
    var title: String
    
    var vaultID: UUID
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Category"
    
    static var defaultQuery = CategoryExpenseIntentQuery()
    
}

struct CategoryExpenseIntentQuery: EntityQuery {
    
    func suggestedEntities() async throws -> [CategoryExpenseIntentEntity] {
        
        guard let vault = UserDefaultsManager.shared.favoriteVault else {
            throw VaultError.vaultNotFound(UUID())
        }
        
        guard let vaultID = UUID(uuidString: vault) else {
            throw VaultError.vaultNotFound(UUID())
        }
        
        let useCase = DependenciesContainer.shared.getListCategoryUseCase()
        
        let request = ListCategoriesRequest(
            vaultID: vaultID,
            operationType: .expense
        )
        
        let response = try useCase.execute(request)
        
        return response.categories.map { category in
            CategoryExpenseIntentEntity(id: category.id, title: category.title, vaultID: vaultID)
        }
    }
    
    func entities(for identifiers: [UUID]) async throws -> [CategoryExpenseIntentEntity] {
        guard let vault = UserDefaultsManager.shared.favoriteVault else {
            throw VaultError.vaultNotFound(UUID())
        }
        
        guard let vaultID = UUID(uuidString: vault) else {
            throw VaultError.vaultNotFound(UUID())
        }
        
        let useCase = DependenciesContainer.shared.getListCategoryUseCase()
        
        let request = ListCategoriesRequest(
            vaultID: vaultID,
            operationType: .expense
        )
        
        let response = try useCase.execute(request)
        
        return response.categories.map { category in
            CategoryExpenseIntentEntity(id: category.id, title: category.title, vaultID: vaultID)
        }
    }
}

struct AddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Expense"
    static var description = IntentDescription("Adds a new expense to Vault.")

    @Parameter(title: "Expense amount")
    var amount: Double
    
    @Parameter(title: "Description")
    var description: String
    
    @Parameter(title: "Category")
    var category: CategoryExpenseIntentEntity
    
    static var parameterSummary: some ParameterSummary {
        // Summary("Add an expense of \(\.$amount) to Vault")
        Summary("Add an expense to Vault")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        let useCase = DependenciesContainer.shared.getAddOperationUseCase()
        
        let userDefaults = UserDefaultsManager.shared
        
        guard let _ = userDefaults.favoriteVault else {
            return .result(
                dialog: IntentDialog("There is no default Vault to add the expense to.")
            )
        }
        
        do {
            
            let request = AddOperationsRequest(
                vaultID: category.vaultID,
                categoryID: category.id,
                amount: amount,
                type: .expense,
                title: description,
                notes: nil,
                date: Date()
            )
            
            let _ = try useCase.execute(request)
            
            return .result(
                dialog: IntentDialog("An expense of \(amount, format: .number) has been added to Vault.")
            )
            
        } catch {
            return .result(
                dialog: IntentDialog("Failed to add the expense of \(amount, format: .number) to Vault.")
            )
        }
        
    }
}
