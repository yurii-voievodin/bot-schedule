//
//  Record.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 25.02.17.
//
//

import Vapor
import HTTP
import FluentProvider

final class Record: Model {
    let storage = Storage()
    
    // MARK: Properties
    
    let auditoriumID: Identifier?
    let groupID: Identifier?
    let teacherID: Identifier?
    
    var date: String
    var pairName: String
    
    var name: String?
    var type: String?
    var time: String
    
    // MARK: - Initialization
    
    init?(_ record: [String: Any]) {
        guard let date = record["DATE_REG"] as? String else { return nil }
        self.date = date
        
        guard let time = record["TIME_PAIR"] as? String else { return nil }
        self.time = time
        
        guard let pairName = record["NAME_PAIR"] as? String else { return nil }
        self.pairName = pairName
        
        name = record["ABBR_DISC"] as? String
        type = record["NAME_STUD"] as? String
        
        // Auditorium
        if let kodAud = record["KOD_AUD"] as? String {
            do {
                let auditorium = try Auditorium.makeQuery().filter(TypableFields.serverID.name, kodAud).first()
                auditoriumID = auditorium?.id
            } catch  {
            }
        }
        // Teacher
        if let kodFio = record["KOD_FIO"] as? String {
            teacherID = Node(stringLiteral: kodFio)
            do {
                let teacher = try Teacher.makeQuery().filter(TypableFields.serverID.name, kodFio).first()
                teacherID = teacher?.id
            } catch  {
            }
        }
        // Group
        if let nameGroup = record["NAME_GROUP"] as? String {
            do {
                let group = try Group.makeQuery().filter("name", nameGroup).first()
                groupID = group?.id
            } catch  {
            }
        }
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Record from the
    /// database row
    init(row: Row) throws {
        date = try row.get("date")
        name = try row.get("name")
        type = try row.get("type")
        time = try row.get("time")
        pairName = try row.get("pair_name")
        
        // Relationships
        auditoriumID = try row.get("auditorium_id")
        groupID = try row.get("group_id")
        teacherID = try row.get("teacher_id")
    }
    
    /// Serializes the Record to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("date", date)
        try row.set("name", name)
        try row.set("type", type)
        try row.set("time", time)
        try row.set("pair_name", pairName)
        
        // Relationships
        try row.set("auditorium_id", auditoriumID)
        try row.set("group_id", groupID)
        try row.set("teacher_id", teacherID)
        
        return row
    }
}

// MARK: - NodeRepresentable

extension Record: NodeRepresentable {
    
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("date", date)
        try node.set("name", name)
        try node.set("type", type)
        try node.set("time", time)
        try node.set("pair_name", pairName)
        
        // Relationships
        try node.set("auditorium_id", auditoriumID)
        try node.set("group_id", groupID)
        try node.set("teacher_id", teacherID)
        
        return node
    }
}

// MARK: - Relationships

extension Record {
    
    var auditorium: Parent<Record, Auditorium> {
        return parent(id: auditoriumID)
    }
    
    var group: Parent<Record, Group> {
        return parent(id: groupID)
    }
    
    var teacher: Parent<Record, Teacher> {
        return parent(id: teacherID)
    }
}

// MARK: - Preparation

extension Record: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { builder in
            builder.id()
            builder.parent(Auditorium.self, optional: true)
            builder.parent(Group.self, optional: true)
            builder.parent(Teacher.self, optional: true)
            builder.string("date")
            builder.string("name", optional: true)
            builder.string("type", optional: true)
            builder.string("time")
            builder.string("pair_name")
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
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
                schedule += newLine + type
            }
            // Name
            if let name = record.name, name.characters.count > 0 {
                schedule += newLine + name
            }
            // Auditorium
            do {
                if let auditorium = try record.auditorium().get() {
                    schedule += newLine + "🚪 " + auditorium.name
                }
            } catch {
            }
            // Teacher
            do {
                if let teacher = try record.teacher.get() {
                    schedule += newLine + "👔 " + teacher.name
                }
            } catch {
            }
            // Group
            do {
                if let group = try record.group().get() {
                    schedule += newLine + "👥 " + group.name
                }
            } catch {
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
