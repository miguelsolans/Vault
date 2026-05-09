//
//  ChatViewModel.swift
//  Vault
//
//  Created by Miguel Solans on 13/04/2026.
//

import Foundation

class ChatViewModel: NSObject {
    
    private let assistant: FinanceAssistant
    
    init(assistant: FinanceAssistant) {
        self.assistant = assistant
    }
    
    // MARK: - State
    
    var screenTitle: String = String(localized: .Chat.pageTitle);
    
    var screenSubtitle: String? = nil;
    
    fileprivate var messages: [ChatMessage] = [
        ChatMessage(
            role: .assistant,
            text: String(localized: .Chat.firstMessage)
        )
    ];
    
    // MARK: - Table
    
    var numberOfRows: Int { messages.count }
    
    func messageRow(at index: IndexPath) -> ChatMessage { messages[index.row] }
    
    // MARK: - Binding
    
    var updateUI: (() -> Void)?
}

extension ChatViewModel {
    func sendPrompt(_ prompt: String) {
        
        if let firstMessage = messages.first {
            
            if (firstMessage.role == .assistant) {
                messages.removeFirst()
            }
        }
        
        
        messages.append(
            .init(role: .user, text: prompt)
        )
        
        updateUI?()
        
        request(prompt)
    }
    
    private func request(_ prompt: String) {
        Task {
            do {
                let response = try await assistant.answer(prompt)
                
                await MainActor.run {
                    messages.append(
                        .init(role: .assistant, text: response)
                    )
                    
                    updateUI?()
                }
                
            } catch {
                // TODO: Present error?
            }
        }
    }
}
