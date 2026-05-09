//
//  ChatViewController.swift
//  Vault
//
//  Created by Miguel Solans on 13/04/2026.
//

import UIKit
import CoreKit

final class ChatViewController: BaseViewController {

    private var viewModel: ChatViewModel

    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let maxTextViewHeight: CGFloat = 100
    private let minTextViewHeight: CGFloat = 36

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        tableView.register(ChatBubbleTableViewCell.self, forCellReuseIdentifier: ChatBubbleTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    private lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 18
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        textView.returnKeyType = .default
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = String(localized: .Chat.askVault)
        label.textColor = .placeholderText
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(String(localized: .Chat.send), for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        return button
    }()

    private lazy var inputContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        return view
    }()

    private var inputContainerBottomConstraint: NSLayoutConstraint?
    private var inputTextViewHeightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindings()
        setupUI()
    }

    override func setupUI() {
        title = viewModel.screenTitle
        navigationItem.subtitle = viewModel.screenSubtitle
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        view.addSubview(inputContainer)

        inputContainer.addSubview(inputTextView)
        inputContainer.addSubview(sendButton)
        inputTextView.addSubview(placeholderLabel)

        inputContainerBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        inputTextViewHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: minTextViewHeight)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor),

            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerBottomConstraint!,

            inputTextView.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            inputTextView.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 12),
            inputTextView.bottomAnchor.constraint(equalTo: inputContainer.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            inputTextViewHeightConstraint!,

            sendButton.leadingAnchor.constraint(equalTo: inputTextView.trailingAnchor, constant: 12),
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
            sendButton.bottomAnchor.constraint(equalTo: inputTextView.bottomAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),

            placeholderLabel.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor, constant: 10),
            placeholderLabel.topAnchor.constraint(equalTo: inputTextView.topAnchor, constant: 8),

            inputTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -12)
        ])
    }

    override func setupBindings() {
        viewModel.updateUI = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.scrollToBottom(animated: true)
        }
    }

    private func scrollToBottom(animated: Bool) {
        guard viewModel.numberOfRows > 0 else { return }
        let lastRow = viewModel.numberOfRows - 1
        let indexPath = IndexPath(row: lastRow, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    private func updateTextViewHeight() {
        let fittingSize = CGSize(width: inputTextView.bounds.width, height: .greatestFiniteMagnitude)
        let calculatedSize = inputTextView.sizeThatFits(fittingSize)
        let newHeight = min(max(calculatedSize.height, minTextViewHeight), maxTextViewHeight)

        inputTextView.isScrollEnabled = calculatedSize.height > maxTextViewHeight
        inputTextViewHeightConstraint?.constant = newHeight
        view.layoutIfNeeded()
    }
}

// MARK: - Actions

extension ChatViewController {
    @objc private func didTapSend() {
        let text = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        viewModel.sendPrompt(text)

        inputTextView.text = ""
        placeholderLabel.isHidden = false
        updateTextViewHeight()

        inputTextView.resignFirstResponder()
        scrollToBottom(animated: true)
    }
}

extension ChatViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatBubbleTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! ChatBubbleTableViewCell

        let message = viewModel.messageRow(at: indexPath)
        cell.configure(with: message)

        return cell
    }
}

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        updateTextViewHeight()
    }
}
