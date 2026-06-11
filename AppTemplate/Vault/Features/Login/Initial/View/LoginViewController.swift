//
//  LoginViewController.swift
//  Vault
//
//  Created by Miguel Solans on 04/04/2026.
//

import UIKit
import CoreKit

final class LoginViewController: BaseViewController {
    
    // MARK: - Dependencies
    fileprivate(set) var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "login_logo")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("login_app_title", tableName:"Login", comment: "")
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 28)
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("login_app_slogan", tableName:"Login", comment: "")
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let pinLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("login_with_pin", tableName:"Login", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let biometricsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("login_with_biometrics", tableName:"Login", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .secondarySystemBackground
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 12
        
        let image = UIImage(systemName: "faceid")
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.semanticContentAttribute = .forceLeftToRight
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        
        return button
    }()
    
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupBindings()
    }
    
    override func setupUI() {
        view.backgroundColor = UIColor(resource: .background)
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(buttonsStackView)
        
        buttonsStackView.addArrangedSubview(pinLoginButton)
        buttonsStackView.addArrangedSubview(biometricsButton)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            buttonsStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            
            pinLoginButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            biometricsButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        biometricsButton.isHidden = viewModel.biometricAuthenticationHidden
    }
    
    private func setupActions() {
        pinLoginButton.addTarget(self, action: #selector(didTapPINLogin), for: .touchUpInside)
        biometricsButton.addTarget(self, action: #selector(didTapBiometrics), for: .touchUpInside)
    }
    
    override func setupBindings() {
        
    }
}

// MARK: - Actions
extension LoginViewController {
    @objc private func didTapPINLogin() {
        viewModel.didTapLogin(type: .pin)
    }
    
    @objc private func didTapBiometrics() {
        viewModel.didTapLogin(type: .biometric)
    }
}
