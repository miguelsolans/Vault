//
//  AddIncomeIntent.swift
//  Vault
//
//  Created by Miguel Solans on 20/04/2026.
//

import AppIntents
import VaultCore

struct CategoryIncomeIntentEntity: AppEntity, Identifiable{
    
    var id: UUID
    
    var title: String
    
    var vaultID: UUID
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Category"
    
    static var defaultQuery = CategoryIncomeIntentQuery()
    
}

struct CategoryIncomeIntentQuery: EntityQuery {
    
    func suggestedEntities() async throws -> [CategoryIncomeIntentEntity] {
        
        guard let vault = UserDefaultsManager.shared.favoriteVault else {
            throw VaultError.vaultNotFound(UUID())
        }
        
        guard let vaultID = UUID(uuidString: vault) else {
            throw VaultError.vaultNotFound(UUID())
        }
        
        let useCase = DependenciesContainer.shared.getListCategoryUseCase()
        
        let request = ListCategoriesRequest(
            vaultID: vaultID,
            operationType: .income
        )
        
        let response = try useCase.execute(request)
        
        return response.categories.map { category in
            CategoryIncomeIntentEntity(id: category.id, title: category.title, vaultID: vaultID)
        }
    }
    
    func entities(for identifiers: [UUID]) async throws -> [CategoryIncomeIntentEntity] {
        guard let vault = UserDefaultsManager.shared.favoriteVault else {
            throw VaultError.vaultNotFound(UUID())
        }
        
        guard let vaultID = UUID(uuidString: vault) else {
            throw VaultError.vaultNotFound(UUID())
        }
        
        let useCase = DependenciesContainer.shared.getListCategoryUseCase()
        
        let request = ListCategoriesRequest(
            vaultID: vaultID,
            operationType: .income
        )
        
        let response = try useCase.execute(request)
        
        return response.categories.map { category in
            CategoryIncomeIntentEntity(id: category.id, title: category.title, vaultID: vaultID)
        }
    }
}

struct AddIncomeIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Add Income"
    
    static var description = IntentDescription("Adds a new income to Vault.")

    @Parameter(title: "Income amount")
    var amount: Double
    
    @Parameter(title: "Description")
    var description: String
    
    @Parameter(title: "Category")
    var category: CategoryIncomeIntentEntity
    
    static var parameterSummary: some ParameterSummary {
        Summary("Add an income to Vault")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        let useCase = DependenciesContainer.shared.getAddOperationUseCase()
        
        let userDefaults = UserDefaultsManager.shared
        
        guard let _ = userDefaults.favoriteVault else {
            return .result(
                dialog: IntentDialog("There is no default Vault to add the income to.")
            )
        }
        
        do {
            
            let request = AddOperationsRequest(
                vaultID: category.vaultID,
                categoryID: category.id,
                amount: amount,
                type: .income,
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
