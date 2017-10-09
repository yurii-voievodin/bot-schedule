//
//  Message.swift
//  App
//
//  Created by Yura Voevodin on 09.10.17.
//

import Foundation

struct Message: JSONInitializable {
    
    let chat: Chat
    let text: String
    
    init(chat: Chat, text: String) {
        self.chat = chat
        self.text = text
    }
    
    init(json: JSON) throws {
        let textFromJSON: String = try json.get("text")
        let cleansedText = textFromJSON.trimmingCharacters(in: .whitespacesAndNewlines)
        try self.init(
            chat: json.get("chat"),
            text: cleansedText
        )
    }
}

// MARK: - Chat

extension Message {
    
    struct Chat: JSONInitializable {
        let id: Int
        
        init(id: Int) {
            self.id = id
        }
        
        init(json: JSON) throws {
            try self.init(
                id: json.get("i")
            )
        }
    }
}
