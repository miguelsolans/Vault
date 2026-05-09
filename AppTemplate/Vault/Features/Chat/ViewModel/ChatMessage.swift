//
//  ChatMessage.swift
//  Vault
//
//  Created by Miguel Solans on 13/04/2026.
//

import Foundation

enum ChatMessageRole {
    case user
    case assistant
}

struct ChatMessage {
    let role: ChatMessageRole
    let text: String
}
