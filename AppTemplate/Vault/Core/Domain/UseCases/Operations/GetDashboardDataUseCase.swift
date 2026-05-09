//  GetDashboardDataUseCase.swift
//  Vault
//
//  Created by Miguel Solans on 18/04/2026.
//

import Foundation

struct GetDashboardDataRequest {
    let vaultID: UUID
    let startDate: Date
    let endDate: Date
}

struct GetDashboardDataResponse {
    let operations: [OperationDTO]
    let metrics: OperationMetrics
}

final class GetDashboardDataUseCase {
    
    private let operationRepository: OperationRepository
    private let vaultRepository: VaultRepository
    
    init(operationRepository: OperationRepository, vaultRepository: VaultRepository) {
        self.operationRepository = operationRepository
        self.vaultRepository = vaultRepository
    }
    
    func execute(_ request: GetDashboardDataRequest) throws -> GetDashboardDataResponse {
        
        guard let vault = try vaultRepository.get(by: request.vaultID) else {
            throw EditVaultError.vaultNotFound(request.vaultID)
        }
        
        let operations = try operationRepository.getAll(from: vault, between: request.startDate, and: request.endDate)
        
        let operationDTOs = operations.map { OperationDTO(operation: $0) }
        let metrics = OperationMetrics.make(from: operations)
        
        return GetDashboardDataResponse(operations: operationDTOs, metrics: metrics)
    }
}