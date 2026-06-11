//
//  AboutViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 01/06/2026.
//

import UIKit
import CoreKit

final class AboutViewModel: NSObject {
    
    public var title: String = L10n.About.pageTitle;
    
    public var subtitle: String = L10n.About.pageSubtitle
    
    // MARK: - UI State
    
    lazy var items: [[MenuOptionTableViewModel]] = {
        return [
            [
                .init(
                    option: .vaults,
                    title: L10n.About.privacyOptionTitle,
                    subtitle: L10n.About.privacyOptionDescription,
                    imageName: "hand.raised.circle",
                    style: .disabled
                )
            ],
            [
                .init(
                    option: .about,
                    title: L10n.About.dashboardOptionTitle,
                    subtitle: L10n.About.dashboardOptionDescription,
                    imageName: "chart.pie",
                    style: .disabled
                ),
                .init(
                    option: .about,
                    title: L10n.About.vaultsOptionTitle,
                    subtitle: L10n.About.vaultsOptionDescription,
                    imageName: "lock.square.stack",
                    style: .disabled
                ),
                .init(
                    option: .about,
                    title: L10n.About.categoriesOptionTitle,
                    subtitle: L10n.About.categoriesOptionDescription,
                    imageName: "tag",
                    style: .disabled
                ),
                .init(
                    option: .about,
                    title: L10n.About.operationsOptionTitle,
                    subtitle: L10n.About.operationsOptionDescription,
                    imageName: "list.bullet",
                    style: .disabled
                ),
                .init(
                    option: .about,
                    title: L10n.About.siriShortcutsOptionTitle,
                    subtitle: L10n.About.siriShortcutsOptionDescription,
                    imageName: "siri",
                    style: .disabled
                )
            ], [
                .init(
                    option: .about,
                    title: L10n.About.versionOptionTitle,
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
        case 0: return L10n.About.general
        case 1: return L10n.About.features
        case 2: return L10n.About.info
        default: return nil
        }
    }
    
    public func titleForFooter(in section: Int) -> String? {
        switch section {
        case 0, 1: return nil
        case 2: return L10n.About.pageFooter
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
