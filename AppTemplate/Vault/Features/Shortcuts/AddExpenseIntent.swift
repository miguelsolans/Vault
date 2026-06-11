//
//  AddExpenseIntent.swift
//  Vault
//
//  Created by Miguel Solans on 20/04/2026.
//

import AppIntents
import VaultCore
import AppUIKit

struct CategoryExpenseIntentEntity: AppEntity, Identifiable{
    
    var id: UUID
    
    var title: String
    
    var vaultID: UUID
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "common.general.category"
    
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
    
    static var title: LocalizedStringResource = "shortcut.addExpense.shortTitle"
    
    static var description = IntentDescription("shortcut.addExpense.description")

    @Parameter(title: "common.general.amount")
    var amount: Double
    
    @Parameter(title: "operation.add.description")
    var description: String
    
    @Parameter(title: "common.general.category")
    var category: CategoryExpenseIntentEntity
    
    static var parameterSummary: some ParameterSummary {
        Summary("shortcut.addExpense.shortTitle")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        let useCase = DependenciesContainer.shared.getAddOperationUseCase()
        
        let userDefaults = UserDefaultsManager.shared
        
        guard let _ = userDefaults.favoriteVault else {
            return .result(
                dialog: IntentDialog(L10n.Shortcuts.noFavoriteVaultError)
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
            
            let text = String(
                format: L10n.Shortcuts.AddExpense.resultSuccess,
                LocalizedDecimalFormatter(numberStyle: .currency)
                    .string(from: amount) ?? "\(amount)"
            )
            
            return .result(
                dialog: IntentDialog(stringLiteral: text)
            )
            
        } catch {
            return .result(
                dialog: IntentDialog(L10n.Shortcuts.noFavoriteVaultError)
            )
        }
    }
}
