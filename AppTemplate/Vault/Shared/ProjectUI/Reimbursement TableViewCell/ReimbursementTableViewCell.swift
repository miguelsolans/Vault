//
//  ReimbursementTableViewCell.swift
//  Vault
//
//  Created by Miguel Solans on 05/05/2026.
//

import UIKit
import VaultCore

class ReimbursementTableViewCell: UITableViewCell {
    
    static let identifier = "TransferMoneyTableViewCell"
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowTitle
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowAmount
        label.textAlignment = .right
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowSubtitle
        label.textAlignment = .right
        return label
    }()
    
    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
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
        selectionStyle = .none
        
        textStackView.addArrangedSubview(amountLabel)
        textStackView.addArrangedSubview(statusLabel)
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(textStackView)
        
        contentView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            amountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        
        textStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

}

// MARK: - Configure
extension ReimbursementTableViewCell {
    
    func configure(with viewModel: ReimbursementTableViewModel) {
        titleLabel.text = viewModel.title
        amountLabel.text = viewModel.formattedAmount
        statusLabel.text = viewModel.status.localized;
        
        configureAmountColor(for: viewModel.status)
        configureStatusColor(for: viewModel.status)
    }
    
    func configureAmountColor(for status: ReimbursementStatus) {
        
    }
    
    func configureStatusColor(for status: ReimbursementStatus) {
        switch status {
        case .expected:
            statusLabel.textColor = .systemOrange
        case .received:
            statusLabel.textColor = .systemGreen
        case .cancelled:
            statusLabel.textColor = .systemRed
        }
    }
}
