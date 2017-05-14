//
//  MessagesController.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 17.04.17.
//
//

import HTTP
import Vapor
import Jobs

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
        Jobs.oneoff {
            do {
                let users = try BotUser.all()
                for user in users {
                    try ResponseManager.shared.sendResponse(user.chatID, text: message)
                }
            } catch {
                print(error)
            }
        }
        return message
    }
}
