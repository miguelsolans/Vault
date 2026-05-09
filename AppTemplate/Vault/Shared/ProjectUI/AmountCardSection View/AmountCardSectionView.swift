//
//  AmountCardSectionView.swift
//  Vault
//
//  Created by Miguel Solans on 06/05/2026.
//

import UIKit

final class AmountCardSectionView: ActionableCardBaseView {
    
    private let titleLabel = UILabel()
    private let gridStack = UIStackView()
    
    override func setupUI() {
        backgroundColor = .systemBackground
        
        titleLabel.font = AppFonts.sectionTitle
        
        gridStack.axis = .vertical
        gridStack.spacing = 12
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStack = UIStackView(arrangedSubviews:[titleLabel, gridStack])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with vm: AmountCardSectionViewModel) {
        titleLabel.text = vm.monthTitle
        
        gridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        vm.gridFormat ? makeGridFormat(vm: vm) : makeRowFormat(vm: vm)
    }
    
    func makeGridFormat(vm: AmountCardSectionViewModel) {
        for chunk in stride(from: 0, to: vm.items.count, by: 2) {
            let rowItems = Array(vm.items[chunk..<min(chunk + 2, vm.items.count)])
            
            let rowStack = UIStackView()
            
            rowStack.axis = .horizontal
            rowStack.spacing = 12
            rowStack.distribution = .fillEqually
            
            for item in rowItems {
                let card = AmountCardItemView()
                card.configure(with: item)
                rowStack.addArrangedSubview(card)
            }
            
            // Fill space if odd
            /*if rowItems.count == 1 {
                rowStack.addArrangedSubview(UIView())
            }*/
            
            gridStack.addArrangedSubview(rowStack)
        }
    }
    
    func makeRowFormat(vm: AmountCardSectionViewModel) {
        
        for item in vm.items {
            
            let card = AmountCardItemView()
            card.configure(with: item)
            
            gridStack.addArrangedSubview(card)
        }
    }
}

#Preview("SummaryHeaderView") {
    let viewModel = AmountCardSectionViewModel(monthTitle: "Section title", items: [
        .init(title: "Card title", amount: 10000, type: nil, budgetAmount:nil),
        .init(title: "Card title", amount: 10000000, type: .income, budgetAmount:nil),
        .init(title: "Card title", amount: 10, type: .income, budgetAmount:nil),
        .init(title: "Card title", amount: 1000000, type: .expense, budgetAmount:nil)
    ], gridFormat: false)
    
    let view = AmountCardSectionView()
    
    view.configure(with: viewModel)
    
    return view
}
