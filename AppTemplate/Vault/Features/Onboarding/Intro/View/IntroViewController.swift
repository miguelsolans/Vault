//
//  IntroViewController.swift
//  Vault
//
//  Created by Miguel Solans on 31/03/2026.
//

import UIKit
import CoreKit

final class IntroViewController: BaseViewController {
    
    // MARK: - Dependencies
    private(set) var viewModel: IntroViewModel
    
    init(viewModel: IntroViewModel) {
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
    
    private var createVaultButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.apply(
            style: ButtonStyles.primary,
            title: String(localized: LocalizedStringResource.Onboarding.introOnboardingGetStarted)
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .background)
        localizationTableName = "Onboarding"
        
        setupCollectionView()
        setupUI()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Ensure layout updates correctly after bounds are set
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = collectionView.bounds.size
        }
    }
    
    // MARK: - Setup
    
    override func setupUI() {
        pageControl.numberOfPages = viewModel.numberOfItems
        
        createVaultButton.addTarget(self, action: #selector(didTapCreateVault), for: .touchUpInside)
        
        view.addSubview(pageControl)
        view.addSubview(createVaultButton)
        
        NSLayoutConstraint.activate([
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 250),
            
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            createVaultButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createVaultButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createVaultButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
            createVaultButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.bringSubviewToFront(pageControl)
        view.bringSubviewToFront(createVaultButton)
    }
    
    private func setupCollectionView() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            OnboardingCollectionViewCell.self,
            forCellWithReuseIdentifier: OnboardingCollectionViewCell.identifier
        )
        
        view.addSubview(collectionView)
    }
    
}

// MARK: - Actions

extension IntroViewController {
    @objc private func didTapCreateVault() {
        viewModel.didTapCreateVault()
    }
}

// MARK: - UICollectionView delegates

extension IntroViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingCollectionViewCell.identifier,
            for: indexPath
        ) as! OnboardingCollectionViewCell
        
        let vm = viewModel.cellViewModel(at: indexPath.item)
        cell.configure(with: vm)
        
        return cell
    }
}

// MARK: - Scroll Handling

extension IntroViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        
        guard width > 0 else { return }
        
        let page = round(scrollView.contentOffset.x / width)
        pageControl.currentPage = Int(page)
    }
}
