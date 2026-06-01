//
//  MarketingViewController.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import UIKit
import CoreKit

final class MarketingViewController: BaseViewController {
    
    // MARK: - Dependencies
    private(set) var viewModel: MarketingViewModel
    
    init(viewModel: MarketingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .systemGray3
        pageControl.currentPageIndicatorTintColor = .label
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        return pageControl
    }()
    
    private var primaryButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Ensure layout updates correctly after bounds are set
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = collectionView.bounds.size
        }
    }
    
    override func setupUI() {
        view.backgroundColor = UIColor(resource: .background)
        title = viewModel.title
        navigationItem.subtitle = viewModel.subtitle
        
        setupCollectionView()
        setupButtons()
        setupConstraints()
    }
    
    override func setupBindings() {
        
    }
}

// MARK: - UI Setup

extension MarketingViewController {
    private func setupCollectionView() {
        pageControl.currentPageIndicatorTintColor = UIColor(resource: .brand)
        
        pageControl.numberOfPages = viewModel.numberOfItems
        pageControl.isHidden = viewModel.numberOfItems <= 1
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            MarketingCollectionViewCell.self,
            forCellWithReuseIdentifier: MarketingCollectionViewCell.identifier
        )
        
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.bringSubviewToFront(pageControl)
    }
    
    private func setupButtons() {
        primaryButton.addTarget(self, action: #selector(didTapPrimaryAction), for: .touchUpInside)
        
        primaryButton.apply(
            style: ButtonStyles.primary,
            title: viewModel.configuration.primaryAction.title
        )
        
        view.addSubview(primaryButton)
        view.bringSubviewToFront(primaryButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 500),
            
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            primaryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            primaryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            primaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
            primaryButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

// MARK: - Actions

extension MarketingViewController {
    @objc private func didTapPrimaryAction() {
        viewModel.didTapPrimaryAction()
    }
}

// MARK: - UICollectionView delegates

extension MarketingViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MarketingCollectionViewCell.identifier,
            for: indexPath
        ) as! MarketingCollectionViewCell
        
        let vm = viewModel.cellViewModel(at: indexPath.item)
        cell.configure(with: vm)
        
        return cell
    }
}

// MARK: - Scroll Handling

extension MarketingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        
        guard width > 0 else { return }
        
        let page = round(scrollView.contentOffset.x / width)
        pageControl.currentPage = Int(page)
    }
}
