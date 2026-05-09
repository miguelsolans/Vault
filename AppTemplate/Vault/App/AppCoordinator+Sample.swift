//
//  AppCoordinator+Sample.swift
//  Vault
//
//  Created by Miguel Solans on 08/04/2026.
//

import UIKit
import CoreKit

// MARK: - Demo UI components

extension AppCoordinator: SampleCoordinatorDelegate {
    
    func setupSampleCoordinator() -> SampleCoordinator {
        let navigationController = UINavigationController()
        
        let coordinator = SampleCoordinator(navigationController: navigationController, dependencies: dependencies)
        
        coordinator.delegate = self
        
        self.addChildCoordinator(coordinator)
        
        coordinator.start()
        
        return coordinator
    }
    
    func coordinatorDidFinish(_ coordinator: SampleCoordinator) {
        removeChildCoordinator(coordinator)
    }
}
