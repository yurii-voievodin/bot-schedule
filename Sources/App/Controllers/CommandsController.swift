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
    let secret: String
    
    // MARK: - Initialization
    
    init(drop: Droplet) throws {
        // Client
        self.client = try drop.config.resolveClient()
        
        // Read the secret key from Config/secrets/app.json.
        guard let secret = drop.config["app", "secret"]?.string else {
            throw BotError.missingSecretKey
        }
        self.secret = secret
        
        // Add routes
        
        // Setting up the POST request with the secret key.
        // With a secret path to be sure that nobody else knows that URL.
        // https://core.telegram.org/bots/api#setwebhook
        drop.post(secret, handler: index)
    }
    
    // MARK: - Methods
    
    func index(request: Request) throws -> ResponseRepresentable {
        RequestsManager.shared.addRequest()
        
        let chatID = request.data["message", "chat", "id"]?.int ?? 0
        let chat = request.data["message", "chat"]?.object
        
        // Message text from request JSON
        let message = (request.data["message", "text"]?.string ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        var responseText = "🙁 За вашим запитом нічого не знайдено, спробуйте інший"
        
        if let data = request.data["callback_query", "data"]?.string {
            // Register user request
            BotUser.registerRequest(for: chat)
            
            // Callback from button
            if data.hasPrefix(ObjectType.auditorium.prefix) {
                // Auditorium
                Jobs.oneoff {
                    let result = try Auditorium.show(for: data, client: self.client, chat: chat)
                    try self.sendResult(result, chatID: chatID)
                }
            } else if data.hasPrefix(ObjectType.group.prefix) {
                // Group
                Jobs.oneoff {
                    let result = try Group.show(for: data, chat: chat, client: self.client)
                    try self.sendResult(result, chatID: chatID)
                }
            } else if data.hasPrefix(ObjectType.teacher.prefix) {
                // Teacher
                Jobs.oneoff {
                    let result = try Teacher.show(for: data, chat: chat, client: self.client)
                    try self.sendResult(result, chatID: chatID)
                }
            }
        } else if let command = BotCommand(rawValue: message) {
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
        } else {
            // Search
            Jobs.oneoff {
                if message.characters.count <= 3 {
                    responseText = "Мінімальна кількість символів для пошуку рівна 4"
                } else {
                    // Auditoriums
                    let auditoriumButtons: [InlineKeyboardButton] = try Auditorium.find(by: message)
                    if !auditoriumButtons.isEmpty {
                        try self.sendResponse(chatID, text: "🚪 Аудиторії", buttons: auditoriumButtons)
                    }
                    
                    // Groups
                    let groupButtons: [InlineKeyboardButton] = try Group.find(by: message)
                    if !groupButtons.isEmpty {
                        try self.sendResponse(chatID, text: "👥 Групи", buttons: groupButtons)
                    }
                    
                    // Teachers
                    let teacherButtons: [InlineKeyboardButton] = try Teacher.find(by: message)
                    if !teacherButtons.isEmpty {
                        try self.sendResponse(chatID, text: "👔 Викладачі", buttons: teacherButtons)
                    }
                    
                    // Register user request
                    BotUser.registerRequest(for: chat)
                    
                    // Empty response
                    if auditoriumButtons.isEmpty && groupButtons.isEmpty && teacherButtons.isEmpty {
                        try self.sendResponse(chatID, text: responseText)
                    }
                }
            }
        }
        // Response with "typing"
        return try JSON(node: ["method": "sendChatAction", "chat_id": chatID, "action": "typing"])
    }
    
    fileprivate func sendResult(_ result: [String], chatID: Int) throws {
        let emptyResponse = "🙁 За вашим запитом нічого не знайдено, спробуйте інший"
        if result.isEmpty {
            try self.sendResponse(chatID, text: emptyResponse)
        } else {
            for row in result  {
                try self.sendResponse(chatID, text: row)
            }
        }
    }
    
    fileprivate func sendResponse(_ chatID: Int, text: String) throws {
        let uri = "https://api.telegram.org/bot\(secret)/sendMessage"
        let request = Request(method: .post, uri: uri)
        request.formURLEncoded = try Node(node: ["method": "sendMessage", "chat_id": chatID, "text": text])
        request.headers = ["Content-Type": "application/x-www-form-urlencoded"]
        let _ = try client.respond(to: request)
    }
    
    fileprivate func sendResponse(_ chatID: Int, text: String, buttons: [InlineKeyboardButton]) throws {
        let uri = "https://api.telegram.org/bot\(self.secret)/sendMessage"
        
        // Make keyboard
        var buttonsArray: [[InlineKeyboardButton]] = []
        for button in buttons {
            buttonsArray.append([button])
        }
        let keyboard = InlineKeyboard(buttonsArray: buttonsArray)
        let keyboardNode = try keyboard.makeNode(in: nil)
        
        // JSON
        var responseData = JSON()
        try responseData.set("method", "sendMessage")
        try responseData.set("chat_id", chatID)
        try responseData.set("text", text)
        try responseData.set("reply_markup", keyboardNode)
        
        // Request
        let request = Request(method: .post, uri: uri)
        request.json = responseData.makeJSON()
        request.headers = ["Content-Type": "application/json"]
        let _ = try self.client.respond(to: request)
    }
}

// MARK: - BotError

extension CommandsController {
    
    /// Bot errors
    enum BotError: Swift.Error {
        /// Missing secret key in Config/secrets/app.json.
        case missingSecretKey
    }
}
