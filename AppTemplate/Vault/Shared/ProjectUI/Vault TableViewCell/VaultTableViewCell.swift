//
//  VaultTableViewCell.swift
//  Vault
//
//  Created by Miguel Solans on 08/04/2026.
//

import UIKit

final class VaultTableViewCell: UITableViewCell {
    
    static let identifier = "VaultTableViewCell"
    
    // MARK: - UI
    
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.secondarySystemBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let favoriteImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: "star.fill")
        iv.tintColor = .systemYellow
        return iv
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
    
    private var titleLeadingToFavoriteConstraint: NSLayoutConstraint!
    private var titleLeadingToCardConstraint: NSLayoutConstraint!
    
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
        cardView.addSubview(favoriteImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(balanceLabel)
        cardView.addSubview(initialDepositLabel)
        
        titleLeadingToFavoriteConstraint = titleLabel.leadingAnchor.constraint(equalTo: favoriteImageView.trailingAnchor, constant: 8)
        titleLeadingToCardConstraint = titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
            
            // Card
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            // Favorite icon
            favoriteImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            favoriteImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            favoriteImageView.widthAnchor.constraint(equalToConstant: 16),
            favoriteImageView.heightAnchor.constraint(equalToConstant: 16),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
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
        
        titleLeadingToCardConstraint.isActive = true
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: VaultTableViewModel) {
        titleLabel.text = viewModel.title
        balanceLabel.text = viewModel.formattedCurrentBalance
        initialDepositLabel.text = viewModel.initialDepositText
        
        favoriteImageView.isHidden = !viewModel.isFavorite
        titleLeadingToFavoriteConstraint.isActive = viewModel.isFavorite
        titleLeadingToCardConstraint.isActive = !viewModel.isFavorite
    }
}


#Preview("VaultTableViewCell") {
    let viewModel = VaultTableViewModel(title: "Title", initialDeposit: 2500, currentBalance: 10000, isFavorite: true)
    let view = VaultTableViewCell()
    
    view.configure(with: viewModel)
    
    return view
}
