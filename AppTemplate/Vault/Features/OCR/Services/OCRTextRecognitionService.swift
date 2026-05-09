//
//  OCRCoordinator.swift
//  Vault
//
//  Created by Miguel Solans on 18/04/2026.
//
import UIKit
import Vision

protocol OCRTextRecognitionServiceProtocol {
    func recognizeText(from image: UIImage, completion: @escaping (Result<String, Error>) -> Void)
}

enum OCRTextRecognitionError: LocalizedError {
    case invalidImage
    case noTextDetected
    case recognitionFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return NSLocalizedString("ocr_invalid_image", tableName: "OCR", comment: "OCR invalid image error")
        case .noTextDetected:
            return NSLocalizedString("ocr_no_text_detected", tableName: "OCR", comment: "OCR no text detected error")
        case let .recognitionFailed(error):
            return error.localizedDescription
        }
    }
}

final class VisionOCRTextRecognitionService: OCRTextRecognitionServiceProtocol {
    func recognizeText(from image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(OCRTextRecognitionError.invalidImage))
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(.failure(OCRTextRecognitionError.recognitionFailed(error)))
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                completion(.failure(OCRTextRecognitionError.noTextDetected))
                return
            }

            let text = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if text.isEmpty {
                completion(.failure(OCRTextRecognitionError.noTextDetected))
            } else {
                completion(.success(text))
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                completion(.failure(OCRTextRecognitionError.recognitionFailed(error)))
            }
        }
    }
}
