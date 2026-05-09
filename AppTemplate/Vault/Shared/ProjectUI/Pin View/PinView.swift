//
//  PinView.swift
//  Vault
//
//  Created by Miguel Solans on 03/04/2026.
//

import SwiftUI

struct PinView: View {
    
    public var viewModel: PinViewModel;
    
    @State private var digits: [Int] = []

    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 28), count: 3)

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 48)

            Text(viewModel.title)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.black)
                .padding(.bottom, 16)

            Text(viewModel.subtitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.gray.opacity(0.8))
                .padding(.bottom, 44)

            HStack(spacing: 26) {
                ForEach(0..<viewModel.numberOfDigits, id: \.self) { index in
                    Circle()
                        .fill(Color.gray.opacity(0.22))
                        .frame(width: 18, height: 18)
                        .overlay(
                            Circle()
                                .fill(Color.gray.opacity(0.45))
                                .opacity(index < digits.count ? 1 : 0)
                        )
                }
            }
            .padding(.bottom, 64)

            LazyVGrid(columns: columns, spacing: 26) {
                ForEach(1...9, id: \.self) { number in
                    keypadButton(title: "\(number)") {
                        appendDigit(number)
                    }
                }

                // Bottom row
                if viewModel.hasFaceID {
                    faceIDButton {
                        handleFaceIDTap()
                    }
                } else {
                    Color.clear
                        .frame(width: 88, height: 88)
                }

                keypadButton(title: "0") {
                    appendDigit(0)
                }

                deleteButton {
                    removeLastDigit()
                }
            }
            .padding(.horizontal, 44)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }

    @ViewBuilder
    private func keypadButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.12))
                    .frame(width: 88, height: 88)

                Text(title)
                    .font(.system(size: 34, weight: .regular))
                    .foregroundColor(.black)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func deleteButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "delete.left")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(.black)
                .frame(width: 88, height: 88)
        }
        .buttonStyle(.plain)
        .opacity(digits.isEmpty ? 0.35 : 1)
        .disabled(digits.isEmpty)
    }

    @ViewBuilder
    private func faceIDButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "faceid")
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(.black)
                .frame(width: 88, height: 88)
        }
        .buttonStyle(.plain)
    }

    private func appendDigit(_ digit: Int) {
        guard digits.count < viewModel.numberOfDigits else { return }
        digits.append(digit)

        if digits.count == viewModel.numberOfDigits {
            let pin = digits.map(String.init).joined()

            viewModel.didEnterPin(pin)
        }
    }

    private func removeLastDigit() {
        guard !digits.isEmpty else { return }
        digits.removeLast()
    }

    private func handleFaceIDTap() {
        viewModel.didTapFaceID()
    }
}

#Preview {
    let viewModel = PinViewModel(
        title: "Create a PIN",
        subtitle: "Enter a 4 digit PIN",
        numberOfDigits: 4,
        hasFaceID: false
    )
    
    PinView(viewModel: viewModel)
}
