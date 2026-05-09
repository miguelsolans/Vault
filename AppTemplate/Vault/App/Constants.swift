//
//  Constants.swift
//  Vault
//
//  Created by Miguel Solans on 30/05/2024.
//

import CoreKit
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
}
