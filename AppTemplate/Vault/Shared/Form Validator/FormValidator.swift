//
//  FormValidator.swift
//  Vault
//
//  Created by Miguel Solans on 03/05/2026.
//

import Foundation
import AppUIKit

public enum NumericCondition {
    case greaterThan(Double)
    case greaterThanOrEqual(Double)
    case lessThan(Double)
    case lessThanOrEqual(Double)
    case equal(Double)
    
    func evaluate(_ value: Double) -> Bool {
        switch self {
        case .greaterThan(let compare):
            return value > compare
        case .greaterThanOrEqual(let compare):
            return value >= compare
        case .lessThan(let compare):
            return value < compare
        case .lessThanOrEqual(let compare):
            return value <= compare
        case .equal(let compare):
            return value == compare
        }
    }
}

public enum FormValidator {
    
    static func validateRequired(
        _ viewModel: TextInputViewModel,
        message: String
    ) -> Bool {
        
        if viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            viewModel.feedback = .error(message)
            return false
        }
        
        viewModel.feedback = .none
        return true
    }
    
    static func validateRequired(
        _ viewModel: TextFieldInputViewModel,
        message: String
    ) -> Bool {
        
        if viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            viewModel.feedback = .error(message)
            return false
        }

        viewModel.feedback = .none
        return true
    }

    static func validatePositiveAmount(
        _ viewModel: TextFieldInputViewModel,
        message: String
    ) -> Bool {
        guard let amount = LocalizedDecimalFormatter().double(from: viewModel.inputText),
              amount > 0 else {
            viewModel.feedback = .error(message)
            return false
        }

        viewModel.feedback = .none
        return true
    }
    
    static func validateAmount(
        _ viewModel: TextFieldInputViewModel,
        condition: NumericCondition,
        message: String
    ) -> Bool {
        
        guard let amount = LocalizedDecimalFormatter().double(from: viewModel.inputText),
              condition.evaluate(amount) else {
            viewModel.feedback = .error(message)
            return false
        }

        viewModel.feedback = .none
        return true
    }
    
    static func validateRequired(
        _ viewModel: OptionInputViewModel,
        message: String
    ) -> Bool {
        
        if viewModel.selectedOption == nil {
            viewModel.feedback = .error(message)
            return false
        }
        
        return true
    }
}
