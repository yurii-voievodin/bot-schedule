//
//  ScheduleRecord.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 25.02.17.
//
//

import Vapor
import Fluent
import Foundation

final class ScheduleRecord: Model {

    // MARK: Properties

    var id: Node?
    var exists: Bool = false

    var auditorium: String
    var date: String
    var day: String
    var group: String
    var name: String
    var order: String
    var teacher: String
    var time: String
    var type: String

    // MARK: - Initialization

    init(auditorium: String, date: String, day: String, group: String, name: String, order: String, teacher: String, time: String, type: String) {
        self.auditorium = auditorium
        self.date = date
        self.day = day
        self.group = group
        self.name = name
        self.order = order
        self.teacher = teacher
        self.time = time
        self.type = type
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        auditorium = try node.extract("auditorium")
        date = try node.extract("date")
        day = try node.extract("day")
        group = try node.extract("group")
        name = try node.extract("name")
        order = try node.extract("order")
        teacher = try node.extract("teacher")
        time = try node.extract("time")
        type = try node.extract("type")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "auditorium": auditorium,
            "date": date,
            "day": day,
            "group": group,
            "name": name,
            "order": order,
            "teacher": teacher,
            "time": time,
            "type": type
            ])
    }
}

// MARK: - Preparation

extension ScheduleRecord: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(entity, closure: { data in
            data.id()
            data.string("auditorium")
            data.string("date")
            data.string("day")
            data.string("groupName")
            data.string("name")
            data.string("teacher")
            data.string("time")
            data.string("type")
        })
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}
