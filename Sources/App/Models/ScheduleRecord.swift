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

    var auditorium: String
    var date: String
    var teacher: String
    var groupName: String

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
            "group_name": groupName
            ])
    }

    init?(_ object: [String: Polymorphic]) {
        guard let auditorium = object["NAME_AUD"]?.string else { return nil }
        self.auditorium = auditorium

        guard let date = object["DATE_REG"]?.string else { return nil }
        self.date = date

        guard let teacher = object["NAME_FIO"]?.string else { return nil }
        self.teacher = teacher

        guard let time = object["TIME_PAIR"]?.string else { return nil }
        self.time = time

        guard let group = object["NAME_GROUP"]?.string else { return nil }
        self.groupName = group

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
            record.string("auditorium")
            record.string("date")
            record.string("teacher")
            record.string("name", optional: true)
            record.string("type", optional: true)
            record.parent(Object.self, optional: false)
            record.string("time")
            record.string("group_name")
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
        var previousDateString = ""

        let records = try ScheduleRecord.query()
            .filter("object_id", .equals, id)
            .sort("date", .descending)
            .sort("time", .descending)
            .all()
        for record in records {
            guard record.auditorium.characters.count > 0 && record.teacher.characters.count > 0 else { continue }

            // Previous date
            if previousDateString.characters.count == 0 {
                previousDateString = record.date
            }

            // Time
            if record.time.characters.count > 0 {
                schedule += "🕐 " + record.time
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
            if record.auditorium.characters.count > 0 {
                schedule += newLine + record.auditorium + " - аудиторія" + newLine
            }

            // Group
            if record.groupName.characters.count > 0 {
                schedule += record.groupName + " - група" + newLine
            }

            // Teacher
            if record.teacher.characters.count > 0 {
                schedule += "👔 " + record.teacher + twoLines
            }

            // Date
            if record.date != previousDateString {
                if let recordDate = Date.serverDate(from: previousDateString)?.humanReadable {
                    schedule += "🗓 " + recordDate + twoLines
                }
                previousDateString = record.date
            }
        }

        // First date
        if let lastRecord = records.last {
            schedule += "🗓 " + lastRecord.date
        }
        
        // Description
        schedule += twoLines + "Розклад для: " + object.name
        
        return schedule
    }
}
