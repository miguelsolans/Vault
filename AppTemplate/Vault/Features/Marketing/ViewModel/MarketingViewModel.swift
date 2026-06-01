//
//  MarketingViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import UIKit

enum AppFeatureAction: Equatable {
    case createVault
}

enum MarketingAction: Equatable {
    case appFeature(AppFeatureAction)
    case dismiss
}

struct MarketingCTA {
    
    public let title: String
    
    public let action: MarketingAction
    
    init(
        title: String,
        action: MarketingAction
    ) {
        self.title = title
        self.action = action
    }
}

struct MarketingConfiguration {
    
    public let pageTitle: String
    
    public let pageSubtitle: String
    
    public let primaryAction: MarketingCTA
    
    public let items: [MarketingItemViewModel]
}

protocol MarketingViewModelDelegate: AnyObject {
    
    func didTapPrimaryAction(_ viewModel: MarketingViewModel, action: MarketingAction)
}

final class MarketingViewModel: NSObject {

    weak var delegate: MarketingViewModelDelegate?
    
    // MARK: - State
    
    private(set) var configuration: MarketingConfiguration
    
    public var title: String {
        configuration.pageTitle
    }
    
    public var subtitle: String  {
        configuration.pageSubtitle
    }
    
    init(configuration: MarketingConfiguration) {
        self.configuration = configuration
    }
    
    public var numberOfItems: Int { configuration.items.count }
    
    public func cellViewModel(at index: Int) -> MarketingItemViewModel { configuration.items[index] }
}

// MARK: - Actions
extension MarketingViewModel {
    
    public func didTapPrimaryAction() {
        delegate?.didTapPrimaryAction(self, action: configuration.primaryAction.action)
    }
}
