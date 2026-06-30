//
//  Constants.swift
//  Vault
//
//  Created by Miguel Solans on 30/05/2024.
//

import CoreKit
import StoreKit
import UIKit

public enum Storyboard: String {
    case welcome = "Welcome"
    case sample  = "Sample"
    case introOnboarding = "Intro"
    case createVault = "CreateVault"
    case listOperations   = "ListOperations"
    case addOperation = "AddOperation"
    case listCategories = "ListCategories"
    case addCategories = "AddCategory"
    
    /// Returns UIStoryboard instance
    public var instance: UIStoryboard {
        return UIStoryboard(name: rawValue, bundle: Bundle.main)
    }
}

struct PlistConstants {
    static let baseURL = "BaseURL";
    static let appBuild = "AppBuild";
    static let appVersion = "AppVersion";
    static let appName = "AppName";
}

struct AppConfig {
    
    static var baseURL: String {
        guard let value: String = PlistReader.value(forKey: PlistConstants.baseURL) else {
            fatalError("Missing BaseURL in Info.plist")
        }
        return value
    }
    
    static var appVersion: String {
        guard let value: String = PlistReader.value(forKey: PlistConstants.appVersion) else {
            fatalError("Missing AppVersion in Info.plist")
        }
        return value
    }
    
    static var buildNumber: String {
        guard let value: String = PlistReader.value(forKey: PlistConstants.appBuild) else {
            fatalError("Missing AppBuild in Info.plist")
        }
        return value
    }
    
    static var appName: String {
        guard let value: String = PlistReader.value(forKey: PlistConstants.appName) else {
            fatalError("Missing AppName in Info.plist")
        }
        return value
    }
    
    static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
}

enum PremiumAccessChecker {
    private static let premiumProductIDs: Set<String> = [
        "com.vault.subscription.monthly",
        "com.vault.subscription.yearly",
        "com.vault.premium.lifetime"
    ]

    static func hasAccess() async -> Bool {
        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let transaction) = entitlement else { continue }

            if premiumProductIDs.contains(transaction.productID) {
                return true
            }
        }

        return false
    }
}

enum PremiumPaywallFactory {
    static func makeConfiguration() -> MarketingConfiguration {
        MarketingConfiguration(
            pageTitle: "Vault Premium",
            pageSubtitle: "Unlock advanced customization and power features.",
            primaryAction: .init(title: "Continue", action: .appFeature(.dismissPaywall)),
            items: [
                .init(
                    imageName: "onboarding_monthly_statistics",
                    title: "Customize Dashboard Widgets",
                    subtitle: "Choose exactly what appears in your dashboard overview."
                ),
                .init(
                    imageName: "onboarding_list_categories",
                    title: "Unlock Category Colors",
                    subtitle: "Personalize categories with colors to scan your data faster."
                ),
                .init(
                    imageName: "onboarding_reimbursements",
                    title: "Multiple Reimbursements",
                    subtitle: "Track more reimbursement flows with premium limits."
                )
            ]
        )
    }
}
