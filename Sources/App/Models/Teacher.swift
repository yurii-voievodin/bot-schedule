//
//  Teacher.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 15.04.17.
//
//

import Vapor
import Fluent
import Foundation

final class Teacher: Typable {

    // MARK: Properties

    var id: Node?
    var exists: Bool = false

    var serverID: Int
    var name: String
    var updatedAt: String
    var lowercaseName: String

    // MARK: Initialization

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        serverID = try node.extract(TypableFields.serverID.name)
        name = try node.extract(TypableFields.name.name)
        updatedAt = try node.extract(TypableFields.updatedAt.name)
        lowercaseName = try node.extract(TypableFields.lowercaseName.name)
    }

    init?(array: [String : Any]) {
        guard let serverID = array[TypableFields.serverID.name] as? Int else { return nil }
        self.serverID = serverID

        guard let name = array[TypableFields.name.name] as? String else { return nil }
        self.name = name

        guard let updatedAt = array[TypableFields.updatedAt.name] as? String else { return nil }
        self.updatedAt = updatedAt

        guard let lowercaseName = array[TypableFields.lowercaseName.name] as? String else { return nil }
        self.lowercaseName = lowercaseName
    }

    // MARK: - Node

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            TypableFields.serverID.name: serverID,
            TypableFields.name.name: name,
            TypableFields.updatedAt.name: updatedAt,
            TypableFields.lowercaseName.name: lowercaseName
            ]
        )
    }
}

// MARK: - Helpers

extension Teacher {

    static func find(by name: String) throws -> String {
        guard name.characters.count > 2 else { return "" }
        var response = ""
        let teachers = try Teacher.query().filter(TypableFields.lowercaseName.name, contains: name.lowercased()).all()
        for teacher in teachers {
            response += teacher.name + " - /teacher_\(teacher.serverID)" + newLine
        }
        guard response.characters.count > 0 else { return "" }
        return twoLines + "👔 Викладачі:" + twoLines + response
    }

    static func show(for message: String) throws -> String {
        // Get ID of teacher from message (/teacher_{id})
        let idString = message.substring(from: message.index(message.startIndex, offsetBy: 9))
        guard let id = Int(idString) else { return "" }

        // Find records for teachers
        guard var teacher = try Teacher.query().filter(TypableFields.serverID.name, id).first() else { return "" }
        let currentHour = Date().dateWithHour
        if teacher.updatedAt != currentHour {
            // Try to delete old records
            try teacher.records().delete()

            // Try to import schedule
            try ScheduleImportManager.importSchedule(for: .teacher, id: teacher.serverID)

            // Update date in object
            teacher.updatedAt = currentHour
            try teacher.save()
        }
        let records = try teacher.records()
            .sort("date", .ascending)
            .sort("pair_name", .ascending)
            .all()

        // Formatting a response
        var response = Record.prepareResponse(for: records)
        response += twoLines +  "👔 Викладач - " + teacher.name
        return response
    }
}

// MARK: - Relationships

extension Teacher {
    func records() throws -> Children<Record> {
        return children()
    }
}

// MARK: - Preparation

extension Teacher: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(entity, closure: { object in
            object.id()
            object.int(TypableFields.serverID.name)
            object.string(TypableFields.name.name)
            object.string(TypableFields.updatedAt.name)
            object.string(TypableFields.lowercaseName.name)
        })
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}
