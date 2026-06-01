//
//  AboutViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 01/06/2026.
//

import UIKit
import CoreKit

final class AboutViewModel: NSObject {
    
    public var title: String = "About";
    
    public var subtitle: String = ""
    
    // MARK: - UI State
    
    lazy var items: [[MenuOptionTableViewModel]] = {
        return [
            [
                .init(
                    option: .vaults,
                    title: "Privacy & Data",
                    subtitle: "Learn how we store your data",
                    imageName: "hand.raised.circle",
                    style: .disabled
                )
            ],
            [
                .init(
                    option: .about,
                    title: "Dashboard",
                    subtitle: "Metrics and analytics",
                    imageName: "chart.pie",
                    style: .disabled
                ),
                .init(
                    option: .about,
                    title: "Vaults",
                    subtitle: "Setup and manage your vaults",
                    imageName: "lock.square.stack",
                    style: .disabled
                ),
                .init(
                    option: .about,
                    title: "Categories",
                    subtitle: "Create and manage categories",
                    imageName: "tag",
                    style: .disabled
                ),
                .init(
                    option: .about,
                    title: "Operations",
                    subtitle: "Register and manage operations",
                    imageName: "list.bullet",
                    style: .disabled
                )
            ], [
                .init(
                    option: .about,
                    title: "Version",
                    subtitle: AppConfig.appVersion,
                    imageName: "info.circle",
                    style: .disabled
                )
            ]
        ]
    }()
    
    public var numberOfSections: Int { items.count }
    
    public func numberOfRows(at section: Int) -> Int { items[section].count }
    
    public func cellViewModel(at indexPath: IndexPath) -> MenuOptionTableViewModel { items[indexPath.section][indexPath.row] }
    
    public func titleForHeader(in section: Int) -> String? {
        switch section {
        case 0: return "General"
        case 1: return "Features"
        case 2: return "Info"
        default: return nil
        }
    }
    
    public func titleForFooter(in section: Int) -> String? {
        switch section {
        case 0, 1: return nil
        case 2: return "Built with ❤️ in Portugal"
        default: return nil
        }
    }
    
    // MARK: - Bindings
    
    public var updateUI: (() -> Void)?
    
    public var onSuccess: ((ViewModelFeedback) -> Void)?
    
    public var onError: ((ViewModelFeedback) -> Void)?
}

// MARK: - Actions

extension AboutViewModel {
    func didSelectRowAtIndex(at indexPath: IndexPath) {
        
    }
}
