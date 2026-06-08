//
//  VaultBaseViewController+Alert.swift
//  Vault
//
//  Created by Miguel Solans on 05/06/2026.
//

import UIKit

extension VaultBaseViewController {
    
    public func presentAlert(with title: String, and message: String, onDismiss: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: L10n.Common.ok, style: .default) { _ in
            onDismiss?()
        }
        
        alert.addAction(okAction);
        
        present(alert, animated: true)
    }
}
