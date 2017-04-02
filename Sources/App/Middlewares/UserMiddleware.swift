//
//  UserMiddleware.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 02.04.17.
//
//

import HTTP
import Foundation

final class UserMiddleware: Middleware {

    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)

        // Get chat and user
        guard let chat = request.data["message", "chat"]?.object, let user = User(chat) else { return response }

        // Try to find user and add new if not found
        var newUser = try User.query().filter("chat_id", .equals, user.chatID).first()
        if newUser == nil {
            try newUser?.save()
        }
        return response
    }
}
