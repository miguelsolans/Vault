//
//  OperationTableViewCell.swift
//  Vault
//
//  Created by Miguel Solans on 30/03/2026.
//

import UIKit
import AppUIKit
import VaultCore

final class OperationTableViewCell: UITableViewCell {
    
    static let identifier = "OperationTableViewCell"
    
    // MARK: - UI
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowTitle
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowSubtitle
        label.textColor = .gray
        return label
    }()
    
    private let totalReimbursementsLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowSubtitle
        label.textColor = .gray
        return label
    }()
    
    private let expectedReimbursementsLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowSubtitle
        label.textColor = .gray
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowAmount
        label.textAlignment = .right
        return label
    }()
    
    private let textStack: UIStackView = {
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
        backgroundColor = UIColor(resource: .accentBackground)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)
        textStack.addArrangedSubview(totalReimbursementsLabel)
        textStack.addArrangedSubview(expectedReimbursementsLabel)
        
        contentStack.addArrangedSubview(emojiBackgroundView)
        contentStack.addArrangedSubview(textStack)
        contentStack.addArrangedSubview(amountLabel)
        
        contentView.addSubview(contentStack)
        
        emojiBackgroundView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 40),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 40),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            
            amountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        
        
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        totalReimbursementsLabel.isHidden = true
        expectedReimbursementsLabel.isEnabled = true
        emojiBackgroundView.isHidden = true
        
    }
}

// MARK: - Configure

extension OperationTableViewCell {
    func configure(with viewModel: OperationTableViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        amountLabel.text = viewModel.formattedAmount
        
        let color = UIColor(hexString: viewModel.color) ?? .clear
        configureEmojiColor(color)
        configureEmoji(viewModel.emoji)
        configureReimbursements(count: viewModel.numberOfReimbursements)
        configureExpectedReimbursements(count: viewModel.expectedReimbursements)
        configureAmountColor(for: viewModel.operationType)
    }
    
    private func configureEmojiColor(_ color: UIColor) {
        emojiBackgroundView.backgroundColor = color.withAlphaComponent(0.5)
    }
    
    private func configureEmoji(_ emoji: String?) {
        emojiLabel.text = emoji
        emojiBackgroundView.isHidden = emoji == nil
    }
    
    private func configureReimbursements(count: Int) {
        guard count > 0 else {
            totalReimbursementsLabel.attributedText = nil
            totalReimbursementsLabel.isHidden = true
            return
        }
        
        let text = "\(count) reimbursement\(count == 1 ? "" : "s")"
        
        totalReimbursementsLabel.setTextWithSystemImage(
            systemName: "arrow.turn.down.right",
            text: text
        )
        
        totalReimbursementsLabel.isHidden = false
    }
    
    private func configureExpectedReimbursements(count: Int) {
        guard count > 0 else {
            expectedReimbursementsLabel.attributedText = nil
            expectedReimbursementsLabel.isHidden = true
            return
        }
        
        let text = "Expecting \(count) reimbursement\(count == 1 ? "" : "s")"
        
        expectedReimbursementsLabel.setTextWithSystemImage(
            systemName: "exclamationmark.triangle",
            text: text,
            tintColor: .systemOrange
        )
        
        expectedReimbursementsLabel.isHidden = false
    }
    
    private func configureAmountColor(for operationType: OperationType) {
        switch operationType {
        case .income:
            amountLabel.textColor = .systemGreen
        case .expense:
            amountLabel.textColor = .systemRed
        }
    }
}

#Preview("OperationTableViewCell") {
    let viewModel = OperationTableViewModel(
        color: "#fff",
        title: "Title",
        subtitle: "Subtitle",
        amount: 100,
        operationType: .income,
        numberOfReimbursements: 0,
        expectedReimbursements: 0
    )

    let view = OperationTableViewCell()
    
    view.configure(with: viewModel)
    
    return view
}
