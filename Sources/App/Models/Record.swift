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
    
    enum ImportError: Error {
        case missingValue
    }
    
    // MARK: Properties
    
    let auditoriumID: Identifier?
    let groupID: Identifier?
    let teacherID: Identifier?
    
    var date: String
    var pairName: String
    
    var name: String?
    var reason: String?
    var type: String?
    var time: String
    
    // MARK: - Initialization
    
    static func row(from json: JSON?) throws -> Record {
        guard let record = json else { throw ImportError.missingValue }
        var row = Row()
        
        guard let date = record["DATE_REG"]?.string else { throw ImportError.missingValue }
        try row.set("date", date)
        
        guard let time = record["TIME_PAIR"]?.string else { throw ImportError.missingValue }
        try row.set("time", time)
        
        guard let pairName = record["NAME_PAIR"]?.string else { throw ImportError.missingValue }
        try row.set("pair_name", pairName)
        
        let name = record["ABBR_DISC"]?.string
        let reason = record["REASON"]?.string
        let type = record["NAME_STUD"]?.string
        try row.set("name", name)
        try row.set("reason", reason)
        try row.set("type", type)
        
        // Auditorium
        if let kodAud = record["KOD_AUD"]?.string {
            let auditorium = try Auditorium.makeQuery().filter(ListObject.Field.serverID.name, kodAud).first()
            try row.set("auditorium_id", auditorium?.id)
        }
        // Teacher
        if let kodFio = record["KOD_FIO"]?.string {
            let teacher = try Teacher.makeQuery().filter(ListObject.Field.serverID.name, kodFio).first()
            try row.set("teacher_id", teacher?.id)
            
        }
        // Group
        if let nameGroup = record["NAME_GROUP"]?.string {
            let group = try Group.makeQuery().filter("name", nameGroup).first()
            try row.set("group_id", group?.id)
        }
        let newRecord = try Record(row: row)
        return newRecord
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Record from the
    /// database row
    init(row: Row) throws {
        date = try row.get("date")
        name = try row.get("name")
        reason = try row.get("reason")
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
        try row.set("reason", reason)
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
            builder.string("reason", optional: true)
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
    
    static func prepareResponse(for records: [Record]) -> [String] {
        var schedule = ""
        var dateString = records.first?.date ?? ""
        var scheduleArray: [String] = []
        
        var groupedByDates: [[Record]] = []
        var rows: [Record] = []
        
        // Fake record
        let fakeRecordJSON: JSON = [
            "DATE_REG": "",
            "NAME_PAIR": "",
            "TIME_PAIR": ""
        ]
        guard let fakeRecord = try? Record.row(from: fakeRecordJSON) else { return [] }
        
        // Add fake record
        var updatedRecords = records
        updatedRecords.append(fakeRecord)
        
        // Sorting records by days
        for record in updatedRecords {
            
            if record.date != dateString {
                dateString = record.date
                groupedByDates.append(rows)
                rows = []
            }
            rows.append(record)
        }
        
        for day in groupedByDates {
            
            // Date of the day
            if let firstRecord = day.first {
                if firstRecord.date != "" {
                    if let recordDate = Date.serverDate(from: firstRecord.date)?.humanReadable {
                        schedule +=  recordDate + twoLines
                    }
                }
            }

            for record in day {
                
                // Pair
                if !record.pairName.isEmpty {
                    schedule += twoLines + record.pairName
                }
                
                // Time
                if !record.time.isEmpty {
                    schedule += newLine + "🕐 " + record.time
                }
                // Type
                if let type = record.type, !type.isEmpty {
                    schedule += newLine + type
                }
                // Name
                if let name = record.name, !name.isEmpty {
                    schedule += newLine + name
                }
                // Reason
                if let reason = record.reason, !reason.isEmpty {
                    schedule += newLine + reason
                }
                
                do {
                    // Auditorium
                    if let auditorium = try record.auditorium.get() {
                        schedule += newLine + "🚪 " + auditorium.name
                    }
                    // Teacher
                    if let teacher = try record.teacher.get() {
                        schedule += newLine + "👔 " + teacher.name
                    }
                    // Group
                    if let group = try record.group.get() {
                        schedule += newLine + "👥 " + group.name
                    }
                } catch {
                }
            }
            
            if !schedule.isEmpty {
                scheduleArray.append(schedule)
                schedule = ""
            }
        }
        return scheduleArray
    }
}
