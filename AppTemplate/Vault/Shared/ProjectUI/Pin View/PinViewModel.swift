//
//  PinViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 03/04/2026.
//

import Foundation

struct PinViewModel {
    /// The title of PIN
    public var title: String = ""
    
    /// The subtitle of PIN
    public var subtitle: String = ""
    
    /// The number of digits for a PIN
    public var numberOfDigits: Int = 4
    
    /// Show FaceID button
    public var hasFaceID: Bool = false
    
    /// Callback when PIN has been entered
    var onDidEnterPin: ((String) -> Void)?
    
    /// Callback on did tap FaceID
    var onDidTapFaceID: (() -> Void)?
    
    init(title: String = "", subtitle: String = "", numberOfDigits: Int = 4, hasFaceID: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.numberOfDigits = numberOfDigits
        self.hasFaceID = hasFaceID
    }
    
    func didEnterPin(_ pin: String) {
        print("PIN entered: \(pin)")
        onDidEnterPin?(pin)
    }
    
    func didTapFaceID() {
        print("Tapped FaceID")
        onDidTapFaceID?()
    }
}
