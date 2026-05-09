//
//  TabBar.swift
//  Vault
//
//  Created by Miguel Solans on 30/05/2024.
//

import UIKit

final class TabBar: UITabBarController {
    
    var viewModel: TabBarViewModel
    
    init(viewModel: TabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }
    
    private func setupAppearance() {
        tabBar.tintColor = viewModel.tintColor
        tabBar.unselectedItemTintColor = viewModel.unselectedColor
        tabBar.isTranslucent = true
    }
}
