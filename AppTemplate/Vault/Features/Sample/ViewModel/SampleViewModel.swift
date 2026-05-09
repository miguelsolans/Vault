//
//  SampleViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 30/03/2026.
//

import UIKit

protocol SampleViewModelDelegate: AnyObject {
    // Declare SampleViewModel delegate functions
}

class SampleViewModel: NSObject {
    
    weak var delegate: SampleViewModelDelegate?
    
    // MARK: - Dependencies
    
    /// Add a list of the dependencies here

    // MARK: - State
    
    /// The screen title in the navigation controller
    let screenTitle: String = "Title";
    
    /// The screen subtitle in the navigation controller
    let screenSubtitle: String? = "A subtitle"
    
}

// MARK: - Actions

extension SampleViewModel {
    /// Public functions, triggered by the ViewController on user action
    /// For example, user presses button continue, `didTapContinue` function is invoked.
}
