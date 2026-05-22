//
//  VaultBaseViewController.swift
//  Vault
//
//  Created by Miguel Solans on 18/04/2026.
//

import UIKit
import CoreKit
import NVActivityIndicatorView

open class VaultBaseViewController: BaseViewController {
    
    private var loadingContentView: UIView?
    private var loadingView: NVActivityIndicatorView?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupLoading()
    }
    
    private func setupLoading() {
        let loadingContentView = UIView()
        loadingContentView.translatesAutoresizingMaskIntoConstraints = false
        loadingContentView.backgroundColor = .black.withAlphaComponent(0.85)
        loadingContentView.isHidden = true
        
        view.addSubview(loadingContentView)
        
        NSLayoutConstraint.activate([
            loadingContentView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let loadingView = NVActivityIndicatorView(
            frame: .zero,
            type: .ballScaleRippleMultiple,
            color: .white,
            padding: 0
        )
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingContentView.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: loadingContentView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: loadingContentView.centerYAnchor),
            loadingView.widthAnchor.constraint(equalToConstant: 60),
            loadingView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        self.loadingContentView = loadingContentView
        self.loadingView = loadingView
    }
    
    func startLoading() {
        guard let loadingContentView else { return }
        
        view.bringSubviewToFront(loadingContentView)
        
        loadingContentView.alpha = 0
        loadingContentView.isHidden = false
        
        loadingView?.startAnimating()
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: {
            loadingContentView.alpha = 1
        })
    }
    
    func stopLoading() {
        guard let loadingContentView else { return }
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: {
            loadingContentView.alpha = 0
        }, completion: { [weak self] _ in
            self?.loadingView?.stopAnimating()
            loadingContentView.isHidden = true
        })
    }
}


extension VaultBaseViewController {
    public func presentAlert(with title: String, and message: String, onDismiss: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            onDismiss?()
            alert.dismiss(animated: true)
        }
        
        alert.addAction(okAction);
        
        present(alert, animated: true)
    }
}
