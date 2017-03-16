//
//  ScheduleRecord.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 25.02.17.
//
//

import Vapor
import HTTP
import Fluent
import Foundation

final class ScheduleRecord: Model {

    // MARK: Properties

    var id: Node?
    var exists: Bool = false

    var objectID: Node?

    var auditorium: String?
    var date: String
    var teacher: String?
    var groupName: String?
    var pairName: String

    var name: String?
    var type: String?
    var time: String

    // MARK: - Initialization

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")

        // Properties
        auditorium = try node.extract("auditorium")
        date = try node.extract("date")
        teacher = try node.extract("teacher")
        name = try node.extract("name")
        type = try node.extract("type")
        time = try node.extract("time")
        groupName = try node.extract("group_name")
        pairName = try node.extract("pair_name")

        // Relationships
        objectID = try node.extract("object_id")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "auditorium": auditorium,
            "date": date,
            "teacher": teacher,
            "name": name,
            "type": type,
            "object_id": objectID,
            "time": time,
            "group_name": groupName,
            "pair_name": pairName
            ])
    }

    init?(_ object: [String: Polymorphic]) {
        auditorium = object["NAME_AUD"]?.string

        guard let date = object["DATE_REG"]?.string else { return nil }
        self.date = date

        teacher = object["NAME_FIO"]?.string

        guard let time = object["TIME_PAIR"]?.string else { return nil }
        self.time = time

        groupName = object["NAME_GROUP"]?.string

        guard let pairName = object["NAME_PAIR"]?.string else { return nil }
        self.pairName = pairName

        self.name = object["ABBR_DISC"]?.string
        self.type = object["NAME_STUD"]?.string
    }
}

// MARK: - Relationships

extension ScheduleRecord {
    func object() throws -> Parent<Object> {
        return try parent(objectID)
    }
}

// MARK: - Preparation

extension ScheduleRecord: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(entity, closure: { record in
            record.id()
            record.string("auditorium", optional: true)
            record.string("date")
            record.string("teacher", optional: true)
            record.string("name", optional: true)
            record.string("type", optional: true)
            record.parent(Object.self, optional: false)
            record.string("time")
            record.string("group_name", optional: true)
            record.string("pair_name")
        })
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

// MARK: - Helpers

extension ScheduleRecord {

    static func findSchedule(by id: Int) throws -> String {
        let currentHour = Date().dateWithHour

        // Try to find object in database
        guard var object = try Object.find(id) else { throw  ScheduleImportManager.ImportError.missingObject }

        if object.updatedAt != currentHour {
            // Try to import schedule
            try ScheduleImportManager.importSchedule(for: object)

            // Update date in object
            object.updatedAt = currentHour
            try object.save()
        }

        var schedule = ""
        var dateString = ""

        let records = try ScheduleRecord.query()
            .filter("object_id", .equals, id)
            .sort("date", .ascending)
            .sort("pair_name", .ascending)
            .all()

        var scheduleArray: [String] = []

        for record in records {
            // Time
            if record.time.characters.count > 0 {
                schedule += newLine + "🕐 " + record.time
            }

            // Type
            if let type = record.type, type.characters.count > 0 {
                schedule += " - " + type
            }

            // Name
            if let name = record.name, name.characters.count > 0 {
                schedule += newLine + name
            }

            // Auditorium
            if let auditorium = record.auditorium, auditorium.characters.count > 0 {
                schedule += newLine + auditorium + " - аудиторія"
            }

            // Group
            if let groupName =  record.groupName, groupName.characters.count > 0 {
                schedule += newLine + groupName + " - група"
            }

            // Teacher
            if let teacher = record.teacher, teacher.characters.count > 0 {
                schedule += newLine + "👔 " + teacher
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

        // Description
        var typeString = ""
        if let type = Object.ObjectType(rawValue: object.type) {
            switch type {
            case .auditorium:
                typeString = "Аудиторія"
            case .group:
                typeString = "Група"
            case .teacher:
                typeString = "Викладач"
            }
            response += twoLines + typeString + " - " + object.name
        }

        return response
    }
}
