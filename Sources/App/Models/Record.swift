//
//  Record.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 25.02.17.
//
//

import Vapor
import HTTP
import Fluent
import Foundation

final class Record: Model {

    // MARK: Properties

    var id: Node?
    var exists: Bool = false

    var auditoriumID: Node?
    var groupID: Node?
    var teacherID: Node?

    var date: String
    var pairName: String

    var name: String?
    var type: String?
    var time: String

    // MARK: - Initialization

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")

        // Properties
        date = try node.extract("date")
        name = try node.extract("name")
        type = try node.extract("type")
        time = try node.extract("time")
        pairName = try node.extract("pair_name")

        // Relationships
        auditoriumID = try node.extract("auditorium_id")
        groupID = try node.extract("group_id")
        teacherID = try node.extract("teacher_id")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "date": date,
            "name": name,
            "type": type,
            "auditorium_id": auditoriumID,
            "group_id": groupID,
            "teacher_id": teacherID,
            "time": time,
            "pair_name": pairName
            ])
    }

    init?(_ record: [String: Polymorphic]) {
        guard let date = record["DATE_REG"]?.string else { return nil }
        self.date = date

        guard let time = record["TIME_PAIR"]?.string else { return nil }
        self.time = time

        guard let pairName = record["NAME_PAIR"]?.string else { return nil }
        self.pairName = pairName

        self.name = record["ABBR_DISC"]?.string
        self.type = record["NAME_STUD"]?.string

        if let kodAud = record["KOD_AUD"]?.string {
            self.auditoriumID = Node(stringLiteral: kodAud)
        }
        if let kodFio = record["KOD_FIO"]?.string {
            self.teacherID = Node(stringLiteral: kodFio)
        }
    }
}

// MARK: - Relationships

extension Record {

    func auditorium() throws -> Parent<Auditorium> {
        return try parent(auditoriumID)
    }

    func group() throws -> Parent<Group> {
        return try parent(groupID)
    }

    func teacher() throws -> Parent<Teacher> {
        return try parent(teacherID)
    }
}

// MARK: - Preparation

extension Record: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(entity, closure: { record in
            record.id()
            record.parent(Auditorium.self, optional: true)
            record.parent(Group.self, optional: true)
            record.parent(Teacher.self, optional: true)
            record.string("date")
            record.string("name", optional: true)
            record.string("type", optional: true)
            record.string("time")
            record.string("pair_name")
        })
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

// MARK: - Helpers

extension Record {

    static func prepareResponse(for records: [Record]) -> String {
        var schedule = ""
        var dateString = ""
        var scheduleArray: [String] = []

        for record in records {
            // Time
            if record.time.characters.count > 0 {
                schedule += twoLines + "🕐 " + record.time
            }
            // Type
            if let type = record.type, type.characters.count > 0 {
                schedule += " - " + type
            }
            // Name
            if let name = record.name, name.characters.count > 0 {
                schedule += newLine + name
            }
            // Date
            if record.date != dateString {
                dateString = record.date
                if let recordDate = Date.serverDate(from: dateString)?.humanReadable {
                    schedule += twoLines + recordDate + " ⬆️"
                }
            }
            if schedule.characters.count > 0 {
                scheduleArray.append(schedule)
                schedule = ""
            }
        }

        // Generate reversed response
        var response = ""
        for item in scheduleArray.reversed() {
            response += item
        }
        return response
    }
}
