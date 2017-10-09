//
//  ResponseManager.swift
//  App
//
//  Created by Yura Voevodin on 09.10.17.
//

import Foundation

class ResponseManager {
    
    let client: ClientFactoryProtocol
    let telegramURI: String
    let secret: String
    
    init(drop: Droplet) throws {
        // Client
        self.client = try drop.config.resolveClient()
        
        // Read the secret key from Config/secrets/app.json.
        guard let secret = drop.config["app", "secret"]?.string else {
            throw BotError.missingSecretKey
        }
        self.secret = secret
        
        // URI
        telegramURI = "https://api.telegram.org/bot\(secret)"
    }
    
    func answerCallbackQuery(id: String) throws {
        let uri = telegramURI + "/answerCallbackQuery"
        let request = Request(method: .post, uri: uri)
        request.formURLEncoded = try Node(node: ["method": "answerCallbackQuery", "callback_query_id": id])
        request.headers = Header.urlencoded.value
        let _ = try client.respond(to: request)
    }
    
    func sendMessage(_ text: String, chatID: Int?) throws {
        guard let id = chatID else { return }
        let uri = telegramURI + "/sendMessage"
        let request = Request(method: .post, uri: uri)
        request.formURLEncoded = try Node(node: ["method": "sendMessage", "chat_id": id, "text": text])
        request.headers = Header.urlencoded.value
        let _ = try client.respond(to: request)
    }
    
    func sendMessage(_ text: String, chatID: Int?, buttons: [InlineKeyboardButton]) throws {
        guard let id = chatID else { return }
        let uri = telegramURI + "/sendMessage"
        
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
        try responseData.set("chat_id", id)
        try responseData.set("text", text)
        try responseData.set("reply_markup", keyboardNode)
        
        // Request
        let request = Request(method: .post, uri: uri)
        request.json = responseData.makeJSON()
        request.headers = Header.json.value
        let _ = try self.client.respond(to: request)
    }
}
