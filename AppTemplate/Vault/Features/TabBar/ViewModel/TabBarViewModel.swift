//
//  TabBarViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import UIKit

struct TabItem {
    let title: String
    let imageName: String
    let selectedImageName: String
    let type: TabType
}

enum TabType {
    case dashboard
    case operations
    case tag
    case settings
    case demoUI
}

final class TabBarViewModel {
    
    private(set) var showDemoUI: Bool = false
    
    lazy var tabs: [TabItem] = {
        var items = [
            TabItem(
                title: L10n.Tab.overview,
                imageName: "house",
                selectedImageName: "house.fill",
                type: .dashboard
            ),
            TabItem(
                title: L10n.Tab.operations,
                imageName: "list.bullet",
                selectedImageName: "list.bullet",
                type: .operations
            ),
            TabItem(
                title: L10n.Tab.categories,
                imageName: "tag",
                selectedImageName: "tag.fill",
                type: .tag
            ),
            TabItem(
                title: L10n.Tab.settings,
                imageName: "gear",
                selectedImageName: "gear",
                type: .settings
            )
        ]
        
        if(showDemoUI) {
            items.append(
                .init(
                    title: L10n.Tab.demo,
                    imageName: "pencil.and.ruler",
                    selectedImageName: "pencil.and.ruler.fill",
                    type: .demoUI
                )
            )
        }
        
        
        return items;
    }();
    
    public var tintColor: UIColor { UIColor(resource: .brand) }
    
    public var unselectedColor: UIColor { .systemGray }
}
