//
//  VaultBaseViewController+Empty.swift
//  Vault
//
//  Created by Miguel Solans on 05/06/2026.
//

import UIKit

public struct EmptyContentConfiguration {
    public let image: UIImage?
    
    public let title: String
    
    public let message: String?
    
    public let buttonTitle: String?
    
    public let buttonImage: UIImage?
    
    public let buttonAction: (() -> Void)?
    
    public init(
        image: UIImage?,
        title: String,
        message: String? = nil,
        buttonTitle: String? = nil,
        buttonImage: UIImage? = nil,
        buttonAction: (() -> Void)? = nil
    ) {
        self.image = image
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonImage = buttonImage
        self.buttonAction = buttonAction
    }
}

extension VaultBaseViewController {
    public func makeEmptyContentView(
        with configuration: EmptyContentConfiguration,
        minimumHeight: CGFloat? = nil
    ) -> UIContentUnavailableView {
        let view = UIContentUnavailableView(
            configuration: makeContentUnavailableConfiguration(from: configuration)
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        if let minimumHeight {
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: minimumHeight).isActive = true
        }
        
        return view
    }
    
    public func updateEmptyContentView(
        _ emptyContentView: UIContentUnavailableView,
        with configuration: EmptyContentConfiguration?
    ) {
        guard let configuration else {
            emptyContentView.isHidden = true
            return
        }
        
        emptyContentView.configuration = makeContentUnavailableConfiguration(from: configuration)
        emptyContentView.isHidden = false
    }
    
    public func updateEmptyContentBackground(
        for tableView: UITableView,
        configuration: EmptyContentConfiguration?
    ) {
        guard let configuration else {
            tableView.backgroundView = nil
            return
        }
        
        tableView.backgroundView = UIContentUnavailableView(
            configuration: makeContentUnavailableConfiguration(from: configuration)
        )
    }
    
    private func makeContentUnavailableConfiguration(
        from emptyContentConfiguration: EmptyContentConfiguration
    ) -> UIContentUnavailableConfiguration {
        var configuration = UIContentUnavailableConfiguration.empty()
        
        configuration.background.backgroundColor = UIColor(resource: .background)
        configuration.image = emptyContentConfiguration.image
        configuration.text = emptyContentConfiguration.title
        configuration.secondaryText = emptyContentConfiguration.message
        
        if let buttonTitle = emptyContentConfiguration.buttonTitle {
            configuration.button = .plain()
            configuration.button.title = buttonTitle
            configuration.button.baseForegroundColor = UIColor(resource: .brand)
            configuration.button.image = emptyContentConfiguration.buttonImage
            configuration.button.imagePlacement = .leading
            configuration.buttonProperties.primaryAction = UIAction { _ in
                emptyContentConfiguration.buttonAction?()
            }
        }
        
        return configuration
    }
}
