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
                title: "Overview",
                imageName: "house",
                selectedImageName: "house.fill",
                type: .dashboard
            ),
            TabItem(
                title: "Operations",
                imageName: "list.bullet",
                selectedImageName: "list.bullet",
                type: .operations
            ),
            TabItem(
                title: "Categories",
                imageName: "tag",
                selectedImageName: "tag.fill",
                type: .tag
            ),
            TabItem(
                title: "Settings",
                imageName: "gear",
                selectedImageName: "gear",
                type: .settings
            )
        ]
        
        if(showDemoUI) {
            items.append(
                .init(
                    title: "Demo",
                    imageName: "pencil.and.ruler",
                    selectedImageName: "pencil.and.ruler.fill",
                    type: .demoUI
                )
            )
        }
        
        
        return items;
    }();
    
    var tintColor: UIColor { .systemBlue }
    
    var unselectedColor: UIColor { .systemGray }
}
