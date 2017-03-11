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
    var type: Int
    var updatedAt: String

    // MARK: - Initialization

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        serverID = try node.extract("server_id")
        name = try node.extract("name")
        type = try node.extract("type")
        updatedAt = try node.extract("updated_at")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "server_id": serverID,
            "name": name,
            "type": type,
            "updated_at": updatedAt
            ])
    }
}

// MARK: - Relationships

extension Object {
    func records() throws -> Children<ScheduleRecord> {
        return children()
    }
}

// MARK: - Preparation

extension Object: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(entity, closure: { data in
            data.id()
            data.int("server_id")
            data.string("name")
            data.int("type")
            data.string("updated_at")
        })
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

// MARK: - Helpers

extension Object {

    static func createOrUpdate(from node: Node) throws {
        guard let serverID = node["server_id"]?.int else { return }

        if var existingObject = try Object.query().filter("server_id", serverID).first() {
            // Find existing
            existingObject.name = try node.extract("name")
            existingObject.type = try node.extract("type")
            existingObject.updatedAt = ""
            try existingObject.save()
        } else {
            // Or create a new one
            var newNode = node
            newNode["updated_at"] = ""
            var newObject = try Object(node: newNode)
            try newObject.save()
        }
    }

    static func importFrom(nodes: [Node]) throws {
        for node in nodes {
            try Object.createOrUpdate(from: node)
        }
    }

    static func findObjects(with name: String) throws -> String {
        var response = ""

        let objects = try Object.query().filter("name", contains: name).all()
        for object in objects {
            if let id = object.id?.int {
                response += object.name + " - /info_\(id)" + "\n"
            }
        }
        return response
    }
}
