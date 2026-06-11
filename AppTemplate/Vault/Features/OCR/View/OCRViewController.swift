//
//  OCRViewController.swift
//  Vault
//
//  Created by Miguel Solans on 17/04/2026.
//

import UIKit
import VisionKit

class OCRViewController: VaultBaseViewController {

    // MARK: - Dependencies

    private(set) var viewModel: OCRViewModel

    init(viewModel: OCRViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func setupUI() {
        presentScanner()
    }
    
    override func setupBindings() {
        viewModel.onRecognitionDidStart = { [weak self] in
            guard let self = self else { return }
            self.startLoading()
        }

        viewModel.onRecognitionDidFinish = { [weak self] in
            guard let self = self else { return }
            self.stopLoading()
        }

        viewModel.onRecognitionDidFail = { [weak self] error in
            guard let self = self else { return }
            self.showRecognitionError(error)
        }
    }


    private func showRecognitionError(_ error: Error) {
        let alert = UIAlertController(
            title: localized("ocr_error_title"),
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        alert.addAction(.init(title: localized("ocr_error_retry"), style: .default) { [weak self] _ in
            self?.presentScanner()
        })

        alert.addAction(.init(title: localized("ocr_error_cancel"), style: .cancel) { [weak self] _ in
            self?.viewModel.didTapDismissCamera()
        })

        present(alert, animated: true)
    }

    func presentScanner() {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = self
        present(scanner, animated: true)
    }
}

extension OCRViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)
        viewModel.didScanDocument(scan)
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true)
        viewModel.didTapDismissCamera()
    }

    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
        viewModel.didTapDismissCamera()
    }
}
