//
//  AboutCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 01/06/2026.
//

import Foundation
import UIKit
import CoreKit

final class AboutCoordinator: BaseCoordinator {
    
    // MARK: - Dependencies
    
    let navigationController: UINavigationController
    
    private let dependencies: DependenciesContainer
    
    init(
        navigationController: UINavigationController,
        dependencies: DependenciesContainer
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = aboutViewController
        self.navigationController.pushViewController(aboutViewController, animated: true)
    }
    
    override func finish() {
        removeAllChildCoordinators()
    }
    
    lazy var aboutViewController: AboutViewController = {
        let viewModel = AboutViewModel()
        
        let viewController = AboutViewController(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        
        return viewController
    }()
}
