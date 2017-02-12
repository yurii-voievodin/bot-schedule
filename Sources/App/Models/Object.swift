//
//  Object.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 12.02.17.
//
//

import Vapor
import Fluent
import Foundation

final class Object: Model {

    // MARK: Properties

    var id: Node?
    var exists: Bool = false

    var serverID: Int
    var name: String

    // MARK: - Initialization

    init(serverID: Int, name: String) {
        self.serverID = serverID
        self.name = name
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        serverID = try node.extract("serverID")
        name = try node.extract("name")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "serverID": serverID,
            "name": name
            ])
    }
}

// MARK: - Preparation

extension Object: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(entity, closure: { data in
            data.id()
            data.int("serverID")
            data.string("name")
        })
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}
