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
                /*.init(
                    imageName: "onboarding_vault",
                    title: "Designed to work offline",
                    subtitle: "No registration required. Experience every feature securely and completely offline."
                ),*/
                .init(
                    imageName: "onboarding_money_flow",
                    title: "Track your spending",
                    subtitle: "Understand where your money goes every month and year."
                ),
                .init(
                    imageName: "onboarding_list_categories",
                    title: "Personalize with categories",
                    subtitle: "Create custom categories and assign them colors that fit your style."
                ),
                .init(
                    imageName: "onboarding_reimbursements",
                    title: "Track reimbursements",
                    subtitle: "Keep shared expenses under control. Record reimbursements and automatically reflect what you actually spent."
                ),
                .init(
                    imageName: "onboarding_list_vaults",
                    title: "Multiple Vaults",
                    subtitle: "Organize different money with separate Vaults."
                ),
                .init(
                    imageName: "onboarding_monthly_statistics",
                    title: "Save smarter",
                    subtitle: "Gain valuable insights into your spending habits and financial progress."
                ),
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
