//
//  SecurityOptionTableViewCell.swift
//  Vault
//
//  Created by Miguel Solans on 03/04/2026.
//

import UIKit

final class SecurityOptionTableViewCell: UITableViewCell {
    
    static let identifier = "SecurityOptionTableViewCell"
    
    // MARK: - Callback
    
    var onToggleChanged: ((Bool) -> Void)?
    
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
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.secondaryValue
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toggleSwitch: UISwitch = {
        let control = UISwitch()
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // MARK: - State
    
    private var currentStyle: MenuOptionStyle?
    
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
        
        valueLabel.text = nil
        valueLabel.isHidden = true
        
        toggleSwitch.isOn = false
        toggleSwitch.isHidden = true
        toggleSwitch.isEnabled = true
        
        accessoryType = .none
        selectionStyle = .default
        contentView.alpha = 1.0
        
        onToggleChanged = nil
        currentStyle = nil
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        selectionStyle = .default
        
        contentView.addSubview(optionImageView)
        contentView.addSubview(labelsStackView)
        contentView.addSubview(valueLabel)
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
            
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: labelsStackView.trailingAnchor, constant: 12),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            toggleSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: labelsStackView.trailingAnchor, constant: 12),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            labelsStackView.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -12)
        ])
        
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: SecurityOptionTableViewModel) {
        currentStyle = viewModel.style
        
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
        
        valueLabel.text = viewModel.valueText
        toggleSwitch.isOn = viewModel.isToggleOn
        
        contentView.alpha = viewModel.isEnabled ? 1.0 : 0.5
        isUserInteractionEnabled = viewModel.isEnabled
        
        switch viewModel.style {
        case .navigable:
            valueLabel.isHidden = viewModel.valueText == nil
            toggleSwitch.isHidden = true
            accessoryType = .disclosureIndicator
            selectionStyle = viewModel.isEnabled ? .default : .none
            
            titleLabel.textColor = .label
            subtitleLabel.textColor = .secondaryLabel
            optionImageView.tintColor = .label
            
        case .toggle:
            valueLabel.isHidden = true
            toggleSwitch.isHidden = false
            toggleSwitch.isEnabled = viewModel.isEnabled
            accessoryType = .none
            selectionStyle = .none
            
            titleLabel.textColor = .label
            subtitleLabel.textColor = .secondaryLabel
            optionImageView.tintColor = .label
            
        case .disabled:
            valueLabel.isHidden = viewModel.valueText == nil
            toggleSwitch.isHidden = true
            accessoryType = .none
            selectionStyle = .none
            
            titleLabel.textColor = .secondaryLabel
            subtitleLabel.textColor = .tertiaryLabel
            optionImageView.tintColor = .secondaryLabel
            
        default:
            break
        }
    }
    
    // MARK: - Actions
    
    @objc private func toggleValueChanged() {
        onToggleChanged?(toggleSwitch.isOn)
    }
}

#Preview("SecurityOptionTableViewCell") {
    
    let viewModel = SecurityOptionTableViewModel(option: .biometricAuthentication, title: "Title", subtitle: "Subtitle", imageName: nil, style: .navigable, valueText: "Value text", isToggleOn: false, isEnabled: true)
    
    let view = SecurityOptionTableViewCell()
    
    view.configure(with: viewModel)
    
    return view
}
