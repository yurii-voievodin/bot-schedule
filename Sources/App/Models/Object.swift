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
    var lowercaseName: String

    // MARK: Initialization

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        serverID = try node.extract("server_id")
        name = try node.extract("name")
        type = try node.extract("type")
        updatedAt = try node.extract("updated_at")
        lowercaseName = try node.extract("lowercase_name")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "server_id": serverID,
            "name": name,
            "type": type,
            "updated_at": updatedAt,
            "lowercase_name": lowercaseName
            ])
    }

    init?(array object: Dictionary<String, Any>) {
        guard let serverID = object["server_id"] as? Int else { return nil }
        self.serverID = serverID

        guard let name = object["name"] as? String else { return nil }
        self.name = name

        guard let type = object["type"] as? Int else { return nil }
        self.type = type

        guard let updatedAt = object["updated_at"] as? String else { return nil }
        self.updatedAt = updatedAt

        guard let lowercaseName = object["lowercase_name"] as? String else { return nil }
        self.lowercaseName = lowercaseName
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
            data.string("lowercase_name")
        })
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

// MARK: - Helpers

extension Object {

    enum ObjectType: Int {
        case auditorium = 0
        case group = 1
        case teacher = 2
    }

    static func find(with name: String) throws -> String {
        var response = ""
        guard name.characters.count > 1 else { return response }

        let objects = try Object.query().filter("lowercase_name", contains: name.lowercased()).all()
        for object in objects {
            if let id = object.id?.int {
                response += object.name + " - /info_\(id)" + newLine
            }
        }
        return response
    }
}
