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
        
        label.font = AppFonts.cardTitle
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        
        label.font = AppFonts.primaryValue
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
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.font = AppFonts.cardTitle
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        
        return stackView
    }()
    
    public override func setupUI() {
        backgroundColor = UIColor(resource: .accentBackground)
        
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(amountLabel)
        verticalStackView.addArrangedSubview(bottomLabel)
        
        addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}

extension AmountCardItemView {
    func configure(with viewModel: AmountCardItemViewModel) {
        super.configure(with: viewModel)
        
        configureTitle(viewModel.title)
        
        amountLabel.text = LocalizedDecimalFormatter(numberStyle: viewModel.numberStyle)
            .string(from: viewModel.amount) ?? "\(viewModel.amount)"
        
        configureAmountColor(for: viewModel.type)
        configureBottomText(viewModel.bottomText, attributedText: viewModel.bottomAttributedText)
    }
    
    private func configureTitle(_ text: String?) {
        let isActionable = viewModel?.isEnabled == true && viewModel?.onTap != nil
        
        titleLabel.text = text
        
        if isActionable, let text {
            titleLabel.setTextWithSystemImage(
                systemName: "arrow.forward.circle",
                text: text,
                side: .right,
                tintColor: .label
            )
        }
    }
    
    private func configureAmountColor(for operationType: OperationType? = nil) {
        guard let operationType else {
            amountLabel.textColor = .label
            return
        }
        
        amountLabel.textColor = (operationType == .expense) ? .systemRed : .systemGreen
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
