//
//  AmountStatusHeaderView.swift
//  Vault
//
//  Created by Miguel Solans on 09/05/2026.
//

import UIKit
import AppUIKit

final class AmountStatusHeaderView: UIView {
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: UI
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Total"
        label.font = AppFonts.rowTitle
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        
        label.font = AppFonts.operationHeaderAmount
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var percentageLabel: UILabel = {
        let label = UILabel()
        
        label.font = AppFonts.rowTitle
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
 
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // MARK: - Lifecycles
    
    private func setupUI() {
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        setupStackItems()
    }
    
    private func setupStackItems() {
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(amountLabel)
        contentStackView.addArrangedSubview(percentageLabel)
    }

}


extension AmountStatusHeaderView {
    public func configure(with viewModel: AmountStatusHeaderViewModel) {
        
        amountLabel.text = viewModel.formattedAmount
        
        let percentageText = viewModel.formattedPercentage
        let rangeText = viewModel.period == .monthly ? " vs last month" : " vs last year"
        let fullText = "\(percentageText)\(rangeText)"
        
        percentageLabel.attributedText = fullText.styled(
            baseAttributes: [
                .font: AppFonts.rowTitle,
                .foregroundColor: UIColor.secondaryLabel
            ],
            highlights: [
                TextHighlight(text: percentageText, attributes: [
                    .font: AppFonts.percentageHighlight,
                    .foregroundColor: viewModel.percentageColor
                ])
            ]
        )
        
        percentageLabel.isHidden = viewModel.isPercentageHidden
    }
}
