//
//  AmountCardItemView.swift
//  Vault
//
//  Created by Miguel Solans on 06/05/2026.
//

import UIKit
import AppUIKit
import VaultCore

final class AmountCardItemView: ActionableCardBaseView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let budgetLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let bottomLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.font = AppFonts.cardTitle
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let valueStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .firstBaseline
        
        return stackView
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        
        return stackView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateStackAxisIfNeeded()
    }
    
    public override func setupUI() {
        titleLabel.font = AppFonts.cardTitle
        titleLabel.textColor = .gray
        
        amountLabel.font = AppFonts.primaryValue
        
        budgetLabel.font = AppFonts.secondaryValue
        budgetLabel.textColor = .secondaryLabel
        
        valueStackView.addArrangedSubview(amountLabel)
        valueStackView.addArrangedSubview(budgetLabel)
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(valueStackView)
        contentStackView.addArrangedSubview(bottomLabel)
        
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    private func updateStackAxisIfNeeded() {
        let availableWidth = valueStackView.bounds.width
        
        let amountWidth = amountLabel.intrinsicContentSize.width
        let budgetWidth = budgetLabel.isHidden ? 0 : budgetLabel.intrinsicContentSize.width
        
        let spacing: CGFloat = budgetLabel.isHidden ? 0 : valueStackView.spacing
        
        let totalWidth = amountWidth + budgetWidth + spacing
        
        if totalWidth > availableWidth {
            valueStackView.axis = .vertical
            valueStackView.alignment = .leading
        } else {
            valueStackView.axis = .horizontal
            valueStackView.alignment = .firstBaseline
        }
    }
}

extension AmountCardItemView {
    func configure(with viewModel: AmountCardItemViewModel) {
        super.configure(with: viewModel)
        
        titleLabel.text = viewModel.title
        amountLabel.text = LocalizedDecimalFormatter(numberStyle: .currency).string(from: viewModel.amount) ?? "0,00€"
        
        configureAmountColor(for: viewModel.type)
        configureBudgetAmount(viewModel.budgetAmount)
        configureBottomText(viewModel.bottomText, attributedText: viewModel.bottomAttributedText)
    }
    
    private func configureAmountColor(for operationType: OperationType? = nil) {
        guard let operationType else {
            amountLabel.textColor = .label
            return
        }
        
        amountLabel.textColor = (operationType == .expense) ? .systemRed : .systemGreen
    }
    
    private func configureBudgetAmount(_ amount: Double? = nil) {
        guard let amount else {
            budgetLabel.text = "";
            budgetLabel.isHidden = true
            return
        }
        
        budgetLabel.text = LocalizedDecimalFormatter(numberStyle: .currency).string(from: amount) ?? "\(amount)"
        budgetLabel.isHidden = false
    }
    
    private func configureBottomText(_ text: String?, attributedText: AttributedString?) {
        bottomLabel.isHidden = true
        bottomLabel.text = nil
        bottomLabel.attributedText = nil
        
        if let text {
            bottomLabel.text = text
            bottomLabel.isHidden = false
        }
        
        if let attributedText {
            bottomLabel.attributedText = NSAttributedString(attributedText)
            bottomLabel.isHidden = false
        }
    }
}
