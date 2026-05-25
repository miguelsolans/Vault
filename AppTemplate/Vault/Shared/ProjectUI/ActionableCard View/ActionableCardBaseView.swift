//
//  ActionableCardBaseView.swift
//  Vault
//
//  Created by Miguel Solans on 06/05/2026.
//

import UIKit

open class ActionableCardBaseView: UIView {
    
    private(set) var viewModel: ActionableCardBaseViewModel?
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(
            target: self,
            action: #selector(didTapCard)
        )
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor(resource: .accentBackground)
        layer.cornerRadius = 12
        setupUI()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor(resource: .accentBackground)
        layer.cornerRadius = 12
        setupUI()
    }
    
    public func setupUI() { }
    
    public func configure(with viewModel: ActionableCardBaseViewModel) {
        self.viewModel = viewModel
        updateTapGesture()
    }
    
    private func updateTapGesture() {
        let isActionable = viewModel?.isEnabled == true && viewModel?.onTap != nil
        isUserInteractionEnabled = isActionable
        
        guard isActionable else {
            removeGestureRecognizer(tapGestureRecognizer)
            return
        }
        
        if gestureRecognizers?.contains(where: { $0 === tapGestureRecognizer }) != true {
            addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @objc private func didTapCard() {
        viewModel?.didTap()
    }
}

// MARK: - Swift Macros
#Preview("BaseInputView") {
    let view = ActionableCardBaseView()
    
    let vc = UIViewController()
    vc.view.backgroundColor = .systemBackground
    
    view.translatesAutoresizingMaskIntoConstraints = false
    vc.view.addSubview(view)
    
    NSLayoutConstraint.activate([
        view.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
        view.centerYAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.centerYAnchor),
        view.leadingAnchor.constraint(greaterThanOrEqualTo: vc.view.leadingAnchor, constant: 16),
        view.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -16)
    ])
    
    return vc
}
