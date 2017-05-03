//
//  MessagesController.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 17.04.17.
//
//

import HTTP
import Vapor

final class MessagesController {
    
    // MARK: - Routes
    
    func addRoutes(drop: Droplet) {
        let auth = drop.grouped("messages")
        auth.get("/", handler: index)
        auth.post("/", handler: postMessage)
    }
    
    // MARK: - Handler
    
    func index(request: Request) throws -> ResponseRepresentable {
        let admin = try request.auth.user() as! Admin
        let parameters = try Node(node: ["admin": admin.makeNode()])
        return try drop.view.make("messages", parameters)
    }
    
    func postMessage(request: Request) throws -> ResponseRepresentable {
        guard let message = request.formURLEncoded?["message"]?.string else {
            return "Missing message"
        }
        
        // TODO: Test code will be deleted
        
        if let myUser = try BotUser.find(23) {
            try ResponseManager.shared.sendResponse(myUser.chatID, text: message)
        }
        return message
    }
}
