//
//  VaultTableViewCell.swift
//  Vault
//
//  Created by Miguel Solans on 08/04/2026.
//

import UIKit
import AppUIKit

final class VaultTableViewCell: UITableViewCell {
    
    static let identifier = "VaultTableViewCell"
    
    // MARK: - UI
    
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(resource: .accentBackground)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowTitle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.primaryValue
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let initialDepositLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowSubtitle
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(balanceLabel)
        cardView.addSubview(initialDepositLabel)
        
        NSLayoutConstraint.activate([
            
            // Card
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: balanceLabel.leadingAnchor, constant: -12),
            
            // Balance
            balanceLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            balanceLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            // Initial deposit
            initialDepositLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            initialDepositLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            initialDepositLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            initialDepositLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }
}

extension VaultTableViewCell {
    func configure(with viewModel: VaultTableViewModel) {
        configureTitle(viewModel.title, isFavorite: viewModel.isFavorite)
        balanceLabel.text = viewModel.formattedCurrentBalance
        initialDepositLabel.text = viewModel.initialDepositText
    }
    
    private func configureTitle(_ title: String, isFavorite: Bool) {
        
        guard isFavorite else {
            titleLabel.text = title
            return
        }
        
        titleLabel.setTextWithSystemImage(
            systemName: "star.fill",
            text: title,
            tintColor: .systemYellow
        )
    }
}


#Preview("VaultTableViewCell") {
    let viewModel = VaultTableViewModel(
        title: "Title",
        initialDeposit: 2500,
        currentBalance: 10000,
        isFavorite: true
    )
    
    let view = VaultTableViewCell()
    
    view.configure(with: viewModel)
    
    return view
}
