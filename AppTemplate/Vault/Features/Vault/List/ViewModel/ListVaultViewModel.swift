//
//  ListVaultViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 08/04/2026.
//

import UIKit
import VaultCore

protocol ListVaultViewModelDelegate: AnyObject {
    func viewModelDidTapCreateVault(_ viewModel: ListVaultViewModel)
    func viewModel(_ viewModel: ListVaultViewModel, didSelectVault vault: VaultDTO)
    func viewModel(_ viewModel: ListVaultViewModel, didTapEditVault vault: VaultDTO)
    func viewModel(_ viewModel: ListVaultViewModel, didTapExportVault vault: VaultDTO, csvContent: String, suggestedFilename: String)
}

final class ListVaultViewModel: NSObject {
    
    weak var delegate: ListVaultViewModelDelegate?
    
    // MARK: - Dependencies
    
    private let listUseCase: ListVaultUseCase
    
    private let deleteUseCase: DeleteVaultUseCase
    
    private let exportUseCase: ExportOperationsUseCase
    
    private let userDefaults: UserDefaultsManager
    
    public let canManageVaults: Bool
    
    init(
        listUseCase: ListVaultUseCase,
        deleteUseCase: DeleteVaultUseCase,
        exportUseCase: ExportOperationsUseCase,
        userDefaults: UserDefaultsManager,
        canManageVaults: Bool
    ) {
        self.listUseCase = listUseCase
        self.deleteUseCase = deleteUseCase
        self.exportUseCase = exportUseCase
        self.userDefaults = userDefaults
        self.canManageVaults = canManageVaults
    }
    
    // MARK: - UI State

    public let title: String = "List of Vaults"
    
    public lazy var subtitle: String = {
        
        if canManageVaults {
           return ""
        }
        
        return "Choose a vault"
    }()
    
    var numberOfRows: Int {
        vaults.count
    }
    
    func cellViewModel(at index: IndexPath) -> VaultTableViewModel {
        
        let vault = vaults[index.row]
        
        return VaultTableViewModel(
            title: vault.name,
            initialDeposit: vault.initialDeposit,
            currentBalance: vault.currentBalance,
            isFavorite: isVaultFavorite(vault)
        )
    }
    
    func isVaultFavorite(_ vault: VaultDTO) -> Bool {
        
        guard let favorite = userDefaults.favoriteVault else { return false }
        
        return vault.id.uuidString == favorite
    }
    
    // MARK: - Data
    
    private var vaults: [VaultDTO] = [] {
        didSet {
            updateUI?()
        }
    }
    
    public var isEditAvailable: Bool {
        return canManageVaults
    }
    
    public var isExportAvailable: Bool {
        return false
    }
    
    public func isDeleteAvailable(cell: VaultTableViewModel) -> Bool {
        return !cell.isFavorite
    }
    
    public func isFavoriteAvailable(cell: VaultTableViewModel) -> Bool {
        return !cell.isFavorite
    }
    
    public var isAddVaultAvailable: Bool {
        return canManageVaults
    }
    
    // MARK: - Bindings
    
    public var updateUI: (() -> Void)?
    
    public var onError: ((String) -> Void)?
    
}

extension ListVaultViewModel {
    func getData() {
        do {
            let request = ListVaultRequest()
            
            let response = try listUseCase.execute(request)
            
            vaults = response.vaults
            
        } catch {
            onError?("There was an error fetching Vaults")
        }
    }
    
    func deleteVault(at index: IndexPath) {
        let vault = vaults[index.row]
        
        do {
            
            let request = DeleteVaultRequest(id: vault.id)
            
            let _ = try deleteUseCase.execute(request: request)
            
            getData()
        } catch {
             onError?("There was an error deleting Vault")
        }
    }
    
    func editVault(at index: IndexPath) {
        let vault = vaults[index.row]
        
        delegate?.viewModel(self, didTapEditVault: vault)
    }
    
    func favoriteVault(at index: IndexPath) {
        let vault = vaults[index.row]
        
        userDefaults.favoriteVault = vault.id.uuidString
        
        updateUI?()
    }
    
    func exportVault(at index: IndexPath) {
        let vault = vaults[index.row]
        
        let request = ExportOperationsRequest(
            vaultID: vault.id,
            csvConfiguration: CSVConfiguration(separator: ";", hasHeader: true)
        )
        
        let useCase = DependenciesContainer.shared.getExportOperationsUseCase()
        
        do {
            let response = try useCase.execute(request)
            
            delegate?.viewModel(self, didTapExportVault: vault, csvContent: response.content, suggestedFilename: response.suggestedFilename)
            
        } catch {
            
            onError?("There was an error exporting Vault")
        }
    }
}

// MARK: - Actions

extension ListVaultViewModel {
    public func didTapCreateVault() {
        
        delegate?.viewModelDidTapCreateVault(self)
    }
    
    public func didSelectVault(at indexPath: IndexPath) {
        let selectedVault = vaults[indexPath.row]
        
        delegate?.viewModel(self, didSelectVault: selectedVault)
    }
}
