//
//  OperationSectionHeaderView.swift
//  Vault
//
//  Created by Miguel Solans on 30/03/2026.
//

import UIKit

final class OperationSectionHeaderView: UITableViewHeaderFooterView {
    
    static let identifier = "OperationSectionHeaderView"
    
    // MARK: - UI
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.groupHeaderTitle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.groupHeaderSubtitle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let monthYearLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.groupHeaderSubtitle
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.groupHeaderAmount
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.backgroundColor = UIColor(resource: .background)
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(textStack)
        contentView.addSubview(amountLabel)
        
        textStack.addArrangedSubview(weekdayLabel)
        textStack.addArrangedSubview(monthYearLabel)
        
        NSLayoutConstraint.activate([
            
            // Day label (left, vertically stretched)
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dayLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Stack (center-left)
            textStack.leadingAnchor.constraint(equalTo: dayLabel.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Amount (right)
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8)
        ])
        
        monthYearLabel.isHidden = true
        amountLabel.isHidden = true
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: OperationSectionHeaderViewModel) {
        dayLabel.text = viewModel.day
        weekdayLabel.text = viewModel.weekday
        monthYearLabel.text = viewModel.monthYear
        amountLabel.text = viewModel.formattedAmount
    }
}

#Preview("OperationSectionHeaderView") {
    let viewModel = OperationSectionHeaderViewModel(date: Date(), amount: 2500)
    
    let view = OperationSectionHeaderView()
    
    view.configure(with: viewModel)
    
    return view
}
