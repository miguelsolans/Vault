//
//  MenuOptionTableViewCell.swift
//  Vault
//
//  Created by Miguel Solans on 02/04/2026.
//

import UIKit

final class MenuOptionTableViewCell: UITableViewCell {
    
    static let identifier = "MenuOptionTableViewCell"
    
    // MARK: - UI
    
    private let optionImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowTitle
        label.numberOfLines = 1
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowSubtitle
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let labelsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .fill
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
        selectionStyle = .default
        
        contentView.addSubview(optionImageView)
        contentView.addSubview(labelsStackView)
        
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            optionImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            optionImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            optionImageView.widthAnchor.constraint(equalToConstant: 22),
            optionImageView.heightAnchor.constraint(equalToConstant: 22),
            
            labelsStackView.leadingAnchor.constraint(equalTo: optionImageView.trailingAnchor, constant: 16),
            labelsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            labelsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: MenuOptionTableViewModel) {
        if let imageName = viewModel.imageName {
            optionImageView.image = UIImage(systemName: imageName)
            optionImageView.isHidden = false
        } else {
            optionImageView.image = nil
            optionImageView.isHidden = true
        }
        
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        subtitleLabel.isHidden = viewModel.subtitle == nil
        
        contentView.alpha = viewModel.style == .disabled ? 0.5 : 1.0
        isUserInteractionEnabled = viewModel.style != .disabled
        
        switch viewModel.style {
        case .navigable:
            titleLabel.textColor = .label
            optionImageView.tintColor = .label
            accessoryType = .disclosureIndicator
            
        case .destructive:
            titleLabel.textColor = .systemRed
            optionImageView.tintColor = .systemRed
            accessoryType = .none
        
        case .disabled:
            titleLabel.textColor = .label
            subtitleLabel.textColor = .label
            optionImageView.tintColor = .label
            accessoryType = .none
            selectionStyle = .none
            
        default:
            break;
        }
    }
}

#Preview("MenuOptionTableViewCell") {
    let viewModel = MenuOptionTableViewModel(option: .about, title: "Title", subtitle: "Subtitle", imageName: nil, style: .navigable)
    
    let view = MenuOptionTableViewCell()
    
    view.configure(with: viewModel)
    
    return view
}
