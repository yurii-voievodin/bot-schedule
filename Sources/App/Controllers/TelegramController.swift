//
//  TelegramController.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 04.03.17.
//
//

import Jobs
import HTTP
import Vapor
import Foundation

final class TelegramController {
    
    // MARK: - Properties
    
    let client: ClientFactoryProtocol
    var responseManager: ResponseManager!
    
    let errorMessage = "Сталася невідома помилка! Напиші, будь ласка, розробнику - @voevodin_yura"
    
    // MARK: - Initialization
    
    init(drop: Droplet) throws {
        responseManager = try ResponseManager(drop: drop)
        client = try drop.config.resolveClient()
        
        // Setting up the POST request with the secret key.
        // With a secret path to be sure that nobody else knows that URL.
        // https://core.telegram.org/bots/api#setwebhook
        drop.post(responseManager.secret, handler: index)
    }
    
    // MARK: - Methods
    
    func index(request: Request) throws -> ResponseRepresentable {
        RequestsManager.shared.addRequest()
        
        // Message from Telegram API
        let message = try? Message(json: request.json?["message"] ?? [:])
        var chatID = message?.chat.id ?? 0
        
        if let query = request.json?["callback_query"] {
            // Callback query
            let callbackQuery = try CallbackQuery(json: query)
            try responseManager.answerCallbackQuery(id: callbackQuery.id)
            
            if let id = callbackQuery.message?.chat.id, let data = callbackQuery.data {
                // Update chat id
                chatID = id
                
                // Callback from button
                if data.hasPrefix(ObjectType.auditorium.prefix) {
                    // Auditorium
                    Jobs.oneoff(action: {
                        let result = try Auditorium.show(for: data, chatID: chatID, client: self.client)
                        try self.sendResult(result, chatID: chatID)
                    }, onError: { error in
                        print(error)
                        try? self.responseManager.sendMessage(self.errorMessage, chatID: chatID)
                    })
                } else if data.hasPrefix(ObjectType.group.prefix) {
                    // Group
                    Jobs.oneoff(action: {
                        let result = try Group.show(for: data, chatID: chatID, client: self.client)
                        try self.sendResult(result, chatID: chatID)
                    }, onError: { error in
                        print(error)
                        try? self.responseManager.sendMessage(self.errorMessage, chatID: chatID)
                    })
                } else if data.hasPrefix(ObjectType.teacher.prefix) {
                    // Teacher
                    Jobs.oneoff(action: {
                        let result = try Teacher.show(for: data, chatID: chatID, client: self.client)
                        try self.sendResult(result, chatID: chatID)
                    }, onError: { error in
                        print(error)
                        try? self.responseManager.sendMessage(self.errorMessage, chatID: chatID)
                    })
                }
            }
        } else if let command = BotCommand(rawValue: message?.text ?? "") {
            // Command
            Jobs.oneoff(action: {
                if command == .history {
                    let buttons: [InlineKeyboardButton] = HistoryRecord.history(for: chatID)
                    if buttons.isEmpty {
                        try self.responseManager.sendMessage("Історія порожня", chatID: chatID)
                    } else {
                        try self.responseManager.sendMessage("Історія запитів", chatID: chatID, buttons: buttons)
                    }
                } else {
                    try self.responseManager.sendMessage(command.response, chatID: chatID)
                }
            }, onError: { error in
                print(error)
                try? self.responseManager.sendMessage(self.errorMessage, chatID: chatID)
            })
        } else {
            // Search
            guard let text = message?.text, text.count >= 4 else {
                let errorText = "Мінімальна кількість символів для пошуку рівна 4"
                return try JSON(node: ["method": "sendMessage", "chat_id": chatID, "text": errorText])
            }
            Jobs.oneoff(action: {
                // Auditoriums
                let auditoriumButtons: [InlineKeyboardButton] = try Auditorium.find(by: message?.text)
                if !auditoriumButtons.isEmpty {
                    try self.responseManager.sendMessage("🚪 Аудиторії", chatID: chatID, buttons: auditoriumButtons)
                }
                // Groups
                let groupButtons: [InlineKeyboardButton] = try Group.find(by: message?.text)
                if !groupButtons.isEmpty {
                    try self.responseManager.sendMessage("👥 Групи", chatID: chatID, buttons: groupButtons)
                }
                // Teachers
                let teacherButtons: [InlineKeyboardButton] = try Teacher.find(by: message?.text)
                if !teacherButtons.isEmpty {
                    try self.responseManager.sendMessage("👔 Викладачі", chatID: chatID, buttons: teacherButtons)
                }
                // Empty response
                if auditoriumButtons.isEmpty && groupButtons.isEmpty && teacherButtons.isEmpty {
                    try self.sendResult([], chatID: chatID)
                }
            }, onError: { error in
                print(error)
                try? self.responseManager.sendMessage(self.errorMessage, chatID: chatID)
            })
        }
        // Register user request
        BotUser.registerRequest(chatID: chatID)
        
        // Response with "typing"
        return try JSON(node: ["method": "sendChatAction", "chat_id": chatID, "action": "typing"])
    }
    
    fileprivate func sendResult(_ result: [String], chatID: Int?) throws {
        let emptyResponse = "🙁 За вашим запитом нічого не знайдено, спробуйте інший"
        if result.isEmpty {
            try responseManager.sendMessage(emptyResponse, chatID: chatID)
        } else {
            for row in result  {
                try responseManager.sendMessage(row, chatID: chatID)
            }
        }
    }
}
