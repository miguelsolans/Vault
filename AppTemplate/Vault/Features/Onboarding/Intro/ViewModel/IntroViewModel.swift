//
//  IntroViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import UIKit

protocol IntroViewModelProtocol: AnyObject {
    func introViewModelDidTapCreateVault(_ viewModel: IntroViewModel)
}

class IntroViewModel: NSObject {

    weak var delegate: IntroViewModelProtocol?
    
    // MARK: - State
    
    var items: [OnboardingItemViewModel] = [
        .init(
            imageName: "onboarding_vault",
            title: NSLocalizedString("intro_onboarding_work_offline_title", tableName: "Onboarding", comment: ""),
            subtitle: NSLocalizedString("intro_onboarding_work_offline_description", tableName: "Onboarding", comment: "")
        ),
        .init(
            imageName: "onboarding_wallet_diag",
            title: NSLocalizedString("intro_onboarding_track_spending_title", tableName: "Onboarding", comment: ""),
            subtitle: NSLocalizedString("intro_onboarding_track_spending_description", tableName: "Onboarding", comment: "")
        ),
        .init(
            imageName: "onboarding_savings",
            title: NSLocalizedString("intro_onboarding_save_smarter_title", tableName: "Onboarding", comment: ""),
            subtitle: NSLocalizedString("intro_onboarding_save_smarter_description", tableName: "Onboarding", comment: "")
        ),
        .init(
            imageName: "onboarding_visual_data",
            title: NSLocalizedString("intro_onboarding_stay_in_control_title", tableName: "Onboarding", comment: ""),
            subtitle: NSLocalizedString("intro_onboarding_stay_in_control_description", tableName: "Onboarding", comment: "")
        )
    ]
    
    var numberOfItems: Int { items.count }
    
    func cellViewModel(at index: Int) -> OnboardingItemViewModel { items[index] }
    
    
}

// MARK: - Actions
extension IntroViewModel {
    public func didTapCreateVault() {
        delegate?.introViewModelDidTapCreateVault(self)
    }
}
