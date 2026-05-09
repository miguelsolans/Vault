//
//  MonthSelectorView.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import UIKit

public final class MonthSelectorView: UIView {
    
    private let viewModel: MonthSelectorViewModel
    
    var onMonthChanged: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemBackground
        view.layer.cornerRadius = 18
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private let selectedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.tertiarySystemBackground
        view.layer.cornerRadius = 14
        view.layer.cornerCurve = .continuous
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let previousMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(UIColor.label.withAlphaComponent(0.45), for: .normal)
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    private let currentMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.label, for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let nextMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(UIColor.label.withAlphaComponent(0.45), for: .normal)
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            previousMonthButton,
            currentMonthButton,
            nextMonthButton
        ])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    public init(viewModel: MonthSelectorViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupBindings()
        apply(state: viewModel.displayState, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(selectedBackgroundView)
        selectedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            // containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 52),
            
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6),
            
            selectedBackgroundView.centerXAnchor.constraint(equalTo: currentMonthButton.centerXAnchor),
            selectedBackgroundView.centerYAnchor.constraint(equalTo: currentMonthButton.centerYAnchor),
            selectedBackgroundView.widthAnchor.constraint(equalTo: currentMonthButton.widthAnchor),
            selectedBackgroundView.heightAnchor.constraint(equalTo: currentMonthButton.heightAnchor)
        ])
        
        previousMonthButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        nextMonthButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRight.direction = .right
        
        addGestureRecognizer(swipeLeft)
        addGestureRecognizer(swipeRight)
    }
    
    private func setupBindings() {
        viewModel.updateUI = { [weak self] state in
            self?.apply(state: state, animated: true)
        }
    }
    
    private func apply(state: MonthSelectorViewModel.DisplayState, animated: Bool) {
        let updates = {
            self.previousMonthButton.setTitle(state.previousMonthText, for: .normal)
            self.currentMonthButton.setTitle(state.currentMonthText, for: .normal)
            self.nextMonthButton.setTitle(state.nextMonthText, for: .normal)
            
            
            self.previousMonthButton.isUserInteractionEnabled = state.canGoPrevious
            self.nextMonthButton.isUserInteractionEnabled = state.canGoNext
            
            
            self.previousMonthButton.alpha = state.canGoPrevious ? 0.45 : 0.2
            self.nextMonthButton.alpha = state.canGoNext ? 0.45 : 0.2
        }
        
        if animated {
            UIView.transition(
                with: containerView,
                duration: 0.2,
                options: [.transitionCrossDissolve, .allowUserInteraction],
                animations: updates
            )
        } else {
            updates()
        }
    }
    
    @objc private func previousTapped() {
        viewModel.goToPreviousMonth()
        onMonthChanged?()
    }
    
    @objc private func nextTapped() {
        viewModel.goToNextMonth()
        onMonthChanged?()
    }
    
    @objc private func handleSwipeLeft() {
        guard viewModel.canGoToNextMonth else { return }
        nextTapped()
    }

    @objc private func handleSwipeRight() {
        guard viewModel.canGoToPreviousMonth else { return }
        previousTapped()
    }
}


#Preview("MonthSelectorView") {
    let viewModel = MonthSelectorViewModel()
    
    let view = MonthSelectorView(viewModel: viewModel)
    
    return view
}
