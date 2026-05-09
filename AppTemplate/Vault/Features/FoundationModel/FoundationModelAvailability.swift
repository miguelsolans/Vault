//
//  FoundationModelAvailability.swift
//  Vault
//
//  Created by Miguel Solans on 18/04/2026.
//

import Foundation
import FoundationModels
import VaultCore

public final class FoundationModelAvailability: NSObject {
    
    // MARK: - Singleton
    
    @MainActor public static let shared = FoundationModelAvailability()
    
    // MARK: - Properties
    
    private(set) var languageModel: SystemLanguageModel
    
    override init() {
        self.languageModel = SystemLanguageModel.default
    }
    
    public var isSupported: Bool {
        get {
            switch languageModel.availability {
            case .available:
                return true
            case .unavailable(_):
                return false
            }
        }
    }
}
