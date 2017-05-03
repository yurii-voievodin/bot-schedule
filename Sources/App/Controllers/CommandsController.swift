//
//  CommandsController.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 04.03.17.
//
//

import Jobs
import HTTP
import Vapor
import Foundation

final class CommandsController {
    
    // MARK: - Properties
    
    let secret: String
    
    // MARK: - Initialization
    
    init(secret: String) {
        self.secret = secret
    }
    
    // MARK: - Methods
    
    func index(request: Request) throws -> ResponseRepresentable {
        let chatID = request.data["message", "chat", "id"]?.int ?? 0
        
        // Message text from request JSON
        let message = (request.data["message", "text"]?.string ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        var responseText = "🙁 За вашим запитом нічого не знайдено, спробуйте інший"
        
        if let command = Command(rawValue: message) {
            // Command
            Jobs.oneoff {
                try ResponseManager.shared.sendResponse(chatID, text: command.response)
            }
        } else if message.hasPrefix(ObjectType.auditorium.prefix) {
            // Auditorium
            Jobs.oneoff {
                let result = try Auditorium.show(for: message)
                if !result.isEmpty {
                    responseText = result
                }
                try ResponseManager.shared.sendResponse(chatID, text: responseText)
            }
        } else if message.hasPrefix(ObjectType.group.prefix) {
            // Group
            Jobs.oneoff {
                let result = try Group.show(for: message)
                if !result.isEmpty {
                    responseText = result
                }
                try ResponseManager.shared.sendResponse(chatID, text: responseText)
            }
        } else if message.hasPrefix(ObjectType.teacher.prefix) {
            // Teacher
            Jobs.oneoff {
                let result = try Teacher.show(for: message)
                if !result.isEmpty {
                    responseText = result
                }
                try ResponseManager.shared.sendResponse(chatID, text: responseText)
            }
        } else {
            // Search
            Jobs.oneoff {
                var searchResults = ""
                searchResults += try Auditorium.find(by: message)
                searchResults += try Group.find(by: message)
                searchResults += try Teacher.find(by: message)
                if !searchResults.isEmpty {
                    responseText = searchResults
                }
                try ResponseManager.shared.sendResponse(chatID, text: responseText)
            }
        }
        // Response with "typing"
        return try JSON(node: ["method": "sendChatAction", "chat_id": chatID, "action": "typing"])
    }
}
