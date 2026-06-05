//
//  AppDelegate.swift
//  Vault
//
//  Created by Miguel Solans on 21/05/2024.
//

import UIKit
import IQKeyboardManagerSwift
import CoreData
import VaultCore
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        IQKeyboardManager.shared.isEnabled = true
        
        populateCurrenciesIfNeeded()
        
        startUp()
        
        return true
    }
    
    /*func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return false;
    }*/

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    private func populateCurrenciesIfNeeded() {
        let useCase = DependenciesContainer.shared.getCurrencySeedUseCase()
        
        let request = CurrencySeedRequest()
        
        do {
            _ = try useCase.execute(request)
        } catch {
            exit(1)
        }
    }
    
    private func startUp() {
        let request = AppStartUpUseCaseRequest(
            appVersion: AppConfig.appVersion
        )
        
        let useCase = DependenciesContainer.shared.getAppStartupUseCase()
        
        do {
            _ = try useCase.execute(request: request)
        } catch {
            exit(1)
        }
    }
    
}

