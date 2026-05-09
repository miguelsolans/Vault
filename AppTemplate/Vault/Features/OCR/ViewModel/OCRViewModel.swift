//
//  OCRViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 17/04/2026.
//

import UIKit
import Vision
import VisionKit

protocol OCRViewModelDelegate: AnyObject {
    func didDismissCamera(_ viewModel: OCRViewModel)
    func didParseTextFromImage(text: String)
}

class OCRViewModel: NSObject {

    weak var delegate: OCRViewModelDelegate?

    private let textRecognitionService: OCRTextRecognitionServiceProtocol

    var onRecognitionDidStart: (() -> Void)?
    var onRecognitionDidFinish: (() -> Void)?
    var onRecognitionDidFail: ((Error) -> Void)?

    init(textRecognitionService: OCRTextRecognitionServiceProtocol = VisionOCRTextRecognitionService()) {
        self.textRecognitionService = textRecognitionService
        super.init()
    }
}

// MARK: - Actions

extension OCRViewModel {

    func didTapDismissCamera() {
        delegate?.didDismissCamera(self)
    }

    func didScanDocument(_ document: VNDocumentCameraScan) {
        let image = document.imageOfPage(at: 0)
        recognizeText(from: image)
    }
}

// MARK: - Recognition

private extension OCRViewModel {

    func recognizeText(from image: UIImage) {
        onRecognitionDidStart?()

        textRecognitionService.recognizeText(from: image) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.onRecognitionDidFinish?()

                switch result {
                case .success(let text):
                    self.delegate?.didParseTextFromImage(text: text)
                case .failure(let error):
                    self.onRecognitionDidFail?(error)
                }
            }
        }
    }
}
