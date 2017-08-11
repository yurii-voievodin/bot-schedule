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
    
    let client: ClientFactoryProtocol
    
    // MARK: - Initialization
    
    init(client: ClientFactoryProtocol) {
        self.client = client
    }
    
    // MARK: - Methods
    
    func index(request: Request) throws -> ResponseRepresentable {
        RequestsManager.shared.addRequest()
        
        let chatID = request.data["message", "chat", "id"]?.int ?? 0
        let chat = request.data["message", "chat"]?.object
        
        // Message text from request JSON
        let message = (request.data["message", "text"]?.string ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        var responseText = "🙁 За вашим запитом нічого не знайдено, спробуйте інший"
        
        if let command = Command(rawValue: message) {
            // Command
            Jobs.oneoff {
                // Register user request
                BotUser.registerRequest(for: chat)
                // Response
                if command == .history {
                    try self.sendResponse(chatID, text: HistoryRecord.history(for: chatID))
                } else {
                    try self.sendResponse(chatID, text: command.response)
                }
            }
        } else if message.hasPrefix(ObjectType.auditorium.prefix) {
            // Auditorium
            Jobs.oneoff {
                let result = try Auditorium.show(for: message, chat: chat, client: self.client)
                if !result.isEmpty {
                    responseText = result
                }
                try self.sendResponse(chatID, text: responseText)
            }
        } else if message.hasPrefix(ObjectType.group.prefix) {
            // Group
            Jobs.oneoff {
                let result = try Group.show(for: message, chat: chat, client: self.client)
                if !result.isEmpty {
                    responseText = result
                }
                try self.sendResponse(chatID, text: responseText)
            }
        } else if message.hasPrefix(ObjectType.teacher.prefix) {
            // Teacher
            Jobs.oneoff {
                let result = try Teacher.show(for: message, chat: chat, client: self.client)
                if !result.isEmpty {
                    responseText = result
                }
                try self.sendResponse(chatID, text: responseText)
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
                // Register user request
                BotUser.registerRequest(for: chat)
                // Response
                try self.sendResponse(chatID, text: responseText)
            }
        }
        // Response with "typing"
        return try JSON(node: ["method": "sendChatAction", "chat_id": chatID, "action": "typing"])
    }
    
    fileprivate func sendResponse(_ chatID: Int, text: String) throws {
        let json = try JSON(node: ["method": "sendMessage", "chat_id": chatID, "text": text])
        let uri = "https://api.telegram.org/bot\(ResponseManager.shared.secret)/sendMessage"
        
        _ = try client.post(uri, query: [:], ["Content-Type": "application/x-www-form-urlencoded"], json.makeBody(), through: [])
    }
}
