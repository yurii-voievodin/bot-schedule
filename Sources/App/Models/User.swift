//
//  User.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 02.04.17.
//
//

import Vapor
import Fluent
import Foundation

final class User: Model {

    // MARK: Properties

    var id: Node?
    var exists: Bool = false

    var chatID: Int
    var firstName: String?
    var lastName: String?
    var requests: Int

    // MARK: - Initialization

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        chatID = try node.extract("chat_id")
        firstName = try node.extract("first_name")
        lastName = try node.extract("last_name")
        requests = try node.extract("requests")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "chat_id": chatID,
            "first_name": firstName,
            "last_name": lastName,
            "requests": requests
            ])
    }

    init?(_ object: [String: Polymorphic]) {
        guard let chatID = object["id"]?.int else { return nil }
        self.chatID = chatID
        self.firstName = object["first_name"]?.string
        self.lastName = object["last_name"]?.string
        self.requests = 0
    }
}

// MARK: - Preparation

extension User: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(entity, closure: { user in
            user.id()
            user.int("chat_id")
            user.string("first_name")
            user.string("last_name")
            user.int("requests")
        })
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

