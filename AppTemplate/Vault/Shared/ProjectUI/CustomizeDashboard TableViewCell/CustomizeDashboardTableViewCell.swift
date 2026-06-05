//
//  CustomizeDashboardTableViewCell.swift
//  Vault
//
//  Created by Miguel Solans on 05/06/2026.
//

import UIKit

final class CustomizeDashboardTableViewCell: UITableViewCell {
    
    static let identifier = "CustomizeDashboardTableViewCell"
    
    // MARK: - Callback
    
    var onToggleChanged: ((Bool) -> Void)?
    
    // MARK: - UI
    
    private let optionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .label
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowTitle
        label.numberOfLines = 0
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
    
    private let toggleSwitch: UISwitch = {
        let control = UISwitch()
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        optionImageView.image = nil
        optionImageView.isHidden = false
        
        titleLabel.text = nil
        subtitleLabel.text = nil
        subtitleLabel.isHidden = false
        
        toggleSwitch.isOn = false
        toggleSwitch.isEnabled = true
        
        accessoryType = .none
        selectionStyle = .none
        contentView.alpha = 1.0
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        selectionStyle = .none
        
        backgroundColor = UIColor(resource: .background)
        
        contentView.addSubview(optionImageView)
        contentView.addSubview(labelsStackView)
        contentView.addSubview(toggleSwitch)
        
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)
        
        toggleSwitch.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            optionImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            optionImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            optionImageView.widthAnchor.constraint(equalToConstant: 22),
            optionImageView.heightAnchor.constraint(equalToConstant: 22),
            
            labelsStackView.leadingAnchor.constraint(equalTo: optionImageView.trailingAnchor, constant: 16),
            labelsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            labelsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            toggleSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: labelsStackView.trailingAnchor, constant: 12),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
        
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: CustomizeDashboardTableViewModel) {
        
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
        
        toggleSwitch.isOn = viewModel.isToggleOn
        
        contentView.alpha = viewModel.isEnabled ? 1.0 : 0.5
        isUserInteractionEnabled = viewModel.isEnabled
        
    }
    
    // MARK: - Actions
    
    @objc private func toggleValueChanged() {
        onToggleChanged?(toggleSwitch.isOn)
    }
}

#Preview("CustomizeDashboardTableViewCell") {
    
    let viewModel = CustomizeDashboardTableViewModel(
        id: UUID(),
        title: "Title",
        subtitle: "A brief description of the widget",
        isToggleOn: true
    )
    
    let view = CustomizeDashboardTableViewCell()
    
    view.configure(with: viewModel)
    
    return view
}
