//
//  OperationDetailHeaderView.swift
//  Vault
//
//  Created by Miguel Solans on 05/05/2026.
//

import UIKit
import VaultCore

final class OperationDetailHeaderView: UIView {

    private let emojiContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 44)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.operationHeaderTitle
        label.numberOfLines = 0
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.operationHeaderAmount
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowTitle
        label.numberOfLines = 0
        return label
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        emojiContainerView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)

        contentStackView.addArrangedSubview(emojiContainerView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(amountLabel)
        contentStackView.addArrangedSubview(dateLabel)
        
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),

            emojiBackgroundView.topAnchor.constraint(equalTo: emojiContainerView.topAnchor),
            emojiBackgroundView.bottomAnchor.constraint(equalTo: emojiContainerView.bottomAnchor),
            emojiBackgroundView.centerXAnchor.constraint(equalTo: emojiContainerView.centerXAnchor),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 88),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 88),

            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor)
        ])

        contentStackView.axis = .vertical
        contentStackView.alignment = .fill

        titleLabel.textAlignment = .center
        amountLabel.textAlignment = .center
        dateLabel.textAlignment = .center
    }
}

extension OperationDetailHeaderView {
    public func configure(with viewModel: OperationDetailHeaderViewModel) {
        titleLabel.text = viewModel.title
        amountLabel.text = viewModel.formattedAmount
        dateLabel.text = viewModel.formattedDate
        dateLabel.isHidden = viewModel.formattedDate == nil
        
        let color = UIColor(hexString: viewModel.color) ?? .clear
        configureEmojiColor(color)
        
        configureEmoji(viewModel.emoji)
        
        configureOperationColor(for: viewModel.operationType)
    }
    
    private func configureEmojiColor(_ color: UIColor) {
        emojiBackgroundView.backgroundColor = color.withAlphaComponent(0.5)
    }
    
    private func configureEmoji(_ emoji: String?) {
        emojiLabel.text = emoji
        emojiContainerView.isHidden = emoji == nil
    }
    
    private func configureOperationColor(for status: OperationType) {
        switch status {
        case .income:
            amountLabel.textColor = .systemGreen
        case .expense:
            amountLabel.textColor = .systemRed
        }
    }
}

#Preview("OeprationDetailHeaderView") {
    let viewModel = OperationDetailHeaderViewModel(
        color: "7A9EB1",
        title: "Title",
        amount: 20000,
        operationType: .income
    )
    
    let view = OperationDetailHeaderView()
    
    view.configure(with: viewModel)
    
    return view
}
