//
//  Session.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 12.03.17.
//
//

import Vapor
import Fluent
import Foundation

final class Session: Model {

    // MARK: Properties

    var id: Node?
    var exists: Bool = false

    var date: String
    var requests: Int

    // MARK: Initialization

    init(date: String, requests: Int) {
        self.date = date
        self.requests = requests
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        date = try node.extract("date")
        requests = try node.extract("requests")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "date": date,
            "requests": requests
            ])
    }
}

// MARK: - Preparation

extension Session: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(entity, closure: { data in
            data.id()
            data.string("date")
            data.int("requests")
        })
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}
