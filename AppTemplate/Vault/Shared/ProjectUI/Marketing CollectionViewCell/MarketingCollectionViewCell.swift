//
//  MarketingCollectionViewCell.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import UIKit

final class MarketingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MarketingCollectionViewCell"
    
    // MARK: - UI
    
    private let imageView: UIImageView = {
        let imaveView = UIImageView()
        imaveView.contentMode = .scaleAspectFit
        imaveView.translatesAutoresizingMaskIntoConstraints = false
        return imaveView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.boldTitle
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.rowSubtitle
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
            
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.70)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: MarketingItemViewModel) {
        imageView.image = UIImage(named: viewModel.imageName)
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
}


#Preview("MarketingCollectionViewCell") {
    let viewModel = MarketingItemViewModel(
        imageName: "onboarding_money_flow",
        title: "Title",
        subtitle: "Subtitle"
    )
    
    let view = MarketingCollectionViewCell()
    
    view.configure(with: viewModel)
    
    return view
}
