//
//  TransferMoneyTableViewCell.swift
//  Vault
//
//  Created by Miguel Solans on 30/04/2026.
//

import UIKit

final class TransferMoneyTableViewCell: UITableViewCell {
    
    static let identifier = "TransferMoneyTableViewCell"
    
    // MARK: - UI
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowAmount
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let sourceVaultLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowSubtitle
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let sourceStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private let arrowImageView: UIImageView = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let imageView = UIImageView(image: UIImage(systemName: "arrow.right", withConfiguration: configuration))
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let destinationVaultLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowTitle
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowSubtitle
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let destinationStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        // accessoryType = .disclosureIndicator

        sourceStack.addArrangedSubview(amountLabel)
        sourceStack.addArrangedSubview(sourceVaultLabel)

        destinationStack.addArrangedSubview(destinationVaultLabel)
        destinationStack.addArrangedSubview(statusLabel)

        sourceStack.translatesAutoresizingMaskIntoConstraints = false
        destinationStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(sourceStack)
        contentView.addSubview(arrowImageView)
        contentView.addSubview(destinationStack)

        NSLayoutConstraint.activate([
            sourceStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            sourceStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sourceStack.trailingAnchor.constraint(lessThanOrEqualTo: arrowImageView.leadingAnchor, constant: -16),
            sourceStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            arrowImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 32),
            arrowImageView.heightAnchor.constraint(equalToConstant: 32),

            destinationStack.leadingAnchor.constraint(greaterThanOrEqualTo: arrowImageView.trailingAnchor, constant: 16),
            destinationStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            destinationStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        destinationStack.alignment = .leading
    }

    
    // MARK: - Configure
    
    func configure(with viewModel: TransferMoneyTableViewModel) {
        amountLabel.text = viewModel.amount
        sourceVaultLabel.text = viewModel.sourceVaultText
        destinationVaultLabel.text = viewModel.destinationVaultName
        statusLabel.text = viewModel.statusText
        statusLabel.textColor = viewModel.statusColor
    }
}

#Preview("TransferMoneyTableViewCell") {
    let viewModel = TransferMoneyTableViewModel(
        amount: "500 €",
        sourceVaultName: "Team Vault",
        destinationVaultName: "Savings",
        status: .received
    )
    
    let view = TransferMoneyTableViewCell()
    
    view.configure(with: viewModel)
    
    return view
}
