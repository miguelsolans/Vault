//
//  ChatBubbleTableViewCell.swift
//  Vault
//
//  Created by Miguel Solans on 13/04/2026.
//

import UIKit

final class ChatBubbleTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "ChatBubbleTableViewCell"

    private let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()

    private var bubbleLeadingConstraint: NSLayoutConstraint?
    private var bubbleTrailingConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)

        bubbleLeadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        bubbleTrailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),

            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14)
        ])

        bubbleLeadingConstraint?.isActive = false
        bubbleTrailingConstraint?.isActive = false
    }

    func configure(with message: ChatMessage) {
        messageLabel.text = message.text

        switch message.role {
        case .user:
            bubbleView.backgroundColor = UIColor.systemBlue
            messageLabel.textColor = .white
            bubbleLeadingConstraint?.isActive = false
            bubbleTrailingConstraint?.isActive = true
        case .assistant:
            bubbleView.backgroundColor = UIColor.secondarySystemBackground
            messageLabel.textColor = .label
            bubbleLeadingConstraint?.isActive = true
            bubbleTrailingConstraint?.isActive = false
        }
    }
}
