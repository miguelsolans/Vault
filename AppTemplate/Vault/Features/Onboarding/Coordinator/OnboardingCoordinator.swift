//
//  OnboardingCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import CoreKit
import UIKit
import VaultCore

protocol OnboardingCoordinatorDelegate: AnyObject {
    func coordinatorDidFinish(_ coordinator: OnboardingCoordinator);
}

final class OnboardingCoordinator: BaseCoordinator {
    
    weak var delegate: OnboardingCoordinatorDelegate?
    
    // MARK: - Dependencies
    
    let navigationController: UINavigationController
    
    private let dependencies: DependenciesContainer
    
    init(navigationController: UINavigationController, dependencies: DependenciesContainer) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        super.init()
    }
    
    // MARK: - Lifecycles
    
    override func start() {
        rootViewController = introViewController
        navigationController.viewControllers = [ introViewController ]
    }
    
    override func finish() {
        removeAllChildCoordinators()
        delegate?.coordinatorDidFinish(self)
    }
    
    // MARK: - ViewController's
    
    lazy var introViewController: MarketingViewController = {
        
        let configuration = MarketingConfiguration(
            pageTitle: "",
            pageSubtitle: "",
            primaryAction: .init(title: "Create Vault", action: .appFeature(.createVault)),
            items: [
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
        )
        
        let viewModel = dependencies.getMarketingViewModel(configuration: configuration)
        
        viewModel.delegate = self
        
        let viewController = MarketingViewController(viewModel: viewModel);
        
        return viewController;
    }();

    lazy var createVaultViewController: VaultFormViewController = {
        
        let viewModel = self.dependencies.getCreateVaultViewModel()
        
        viewModel.delegate = self;
        
        let viewController = VaultFormViewController(viewModel: viewModel)
        
        return viewController;
    }();
}

// MARK: - MarketingViewController delegates
extension OnboardingCoordinator: MarketingViewModelDelegate {
    
    func didTapPrimaryAction(_ viewModel: MarketingViewModel, action: MarketingAction) {
        if action == .appFeature(.createVault) {
            self.goToCreateVault()
        }
    }
}

// MARK: - VaultFormViewModel delegates
extension OnboardingCoordinator: VaultFormViewModelDelegate {
    func didCreateVault(_ viewModel: VaultFormViewModel, vault: VaultCore.VaultDTO, with fileURL: URL?) {
        finish()
        
        guard let fileURL = fileURL else {
            finish()
            return
        }
        
        goToImportOperations(with: vault, andFileURL: fileURL)
    }
    
    func didUpdateVault(_ viewModel: VaultFormViewModel, vault: VaultCore.VaultDTO) {
        finish()
    }
    
    func goToCreateVault() {
        
        let coordinator = CreateVaultCoordinator(
            navigationController: navigationController,
            dependencies: dependencies
        )
        
        coordinator.delegate = self
        
        self.addChildCoordinator(coordinator)
        
        coordinator.start()
    }
}

// MARK: - ImportOperationsCoordinator delegates
extension OnboardingCoordinator: ImportOperationsCoordinatorDelegate {
    
    func goToImportOperations(with vault: VaultDTO, andFileURL url: URL) {
        
        let coordinator = ImportOperationsCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            vault: vault,
            fileURL: url
        )
        
        coordinator.delegate = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func coordinatorDidFinish(_ coordinator: ImportOperationsCoordinator) {
        finish()
    }
}

extension OnboardingCoordinator: CreateVaultCoordinatorDelegate {
    
    func coordinatorDidFinish(_ coordinator: CreateVaultCoordinator) {
        delegate?.coordinatorDidFinish(self)
    }
}
