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
import Foundation

final class Record: Model {
    let storage = Storage()
    
    // MARK: Properties
    
    let auditoriumID: Identifier?
    let groupID: Identifier?
    let teacherID: Identifier?
    
    var date: Date
    var dateString: String
    var pairName: String
    
    var name: String?
    var reason: String?
    var type: String?
    var time: String
    
    // MARK: - Initialization
    
    init(date: Date, dateString: String, pairName: String, time: String) {
        auditoriumID = nil
        groupID = nil
        teacherID = nil
        
        self.date = date
        self.dateString = dateString
        self.pairName = pairName
        
        name = nil
        reason = nil
        type = nil
        self.time = time
    }
    
    static func row(from json: JSON?) throws -> Record {
        let importError = ImportError.failedToImportRecord
        guard let record = json else { throw importError }
        var row = Row()
        
        guard let dateString = record["DATE_REG"]?.string else { throw importError }
        try row.set("dateString", dateString)
        
        guard let date = Date.serverDate(from: dateString) else { throw importError }
        try row.set("date", date)
        
        guard let time = record["TIME_PAIR"]?.string else { throw importError }
        try row.set("time", time)
        
        guard let pairName = record["NAME_PAIR"]?.string else { throw importError }
        try row.set("pair_name", pairName)
        
        let name = record["ABBR_DISC"]?.string
        let reason = record["REASON"]?.string
        let type = record["NAME_STUD"]?.string
        try row.set("name", name)
        try row.set("reason", reason)
        try row.set("type", type)
        
        // Auditorium
        if let kodAud = record["KOD_AUD"]?.string {
            let auditorium = try Auditorium.makeQuery().filter(Field.serverID.name, kodAud).first()
            try row.set("auditorium_id", auditorium?.id)
        }
        // Teacher
        if let kodFio = record["KOD_FIO"]?.string {
            let teacher = try Teacher.makeQuery().filter(Field.serverID.name, kodFio).first()
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
        dateString = try row.get("dateString")
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
        try row.set("dateString", dateString)
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

// MARK: JSON
// How the model converts from / to JSON.
extension Record: JSONConvertible {
    
    convenience init(json: JSON) throws {
        let dateString: String = try json.get("date")
        guard let date = Date.serverDate(from: dateString) else { throw ImportError.failedToImportRecord }
        
        try self.init(
            date: date,
            dateString: json.get("dateString"),
            pairName: json.get("pairName"),
            time: json.get("time"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        // Auditorium
        if let auditorium = try auditorium.get() {
            try json.set("auditorium", auditorium)
        }
        // Teacher
        if let teacher = try teacher.get() {
            try json.set("teacher", teacher)
        }
        // Group
        if let group = try group.get() {
            try json.set("group", group)
        }
        
        try json.set("date_string", dateString)
        try json.set("pair_name", pairName)
        
        if let name = name {
            try json.set("name", name)
        }
        if let reason = reason {
            try json.set("reason", reason)
        }
        if let type = type {
            try json.set("type", type)
        }
        try json.set("time", time)
        
        return json
    }
}

// MARK: HTTP
// This allows Record models to be returned
// directly in route closures
extension Record: ResponseRepresentable { }

// MARK: - Preparation

extension Record: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { builder in
            builder.id()
            builder.parent(Auditorium.self, optional: true)
            builder.parent(Group.self, optional: true)
            builder.parent(Teacher.self, optional: true)
            
            builder.custom("date", type: "Date")
            builder.string("dateString")
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
    
    static func prepareResponse(for records: [Record]) throws -> [String] {
        var schedule = ""
        var dateString = records.first?.dateString ?? ""
        var scheduleArray: [String] = []
        
        var groupedByDates: [[Record]] = []
        var rows: [Record] = []
        
        // Sorting records by days
        let countOfRecords = records.count
        let lastIndex = (countOfRecords > 0) ? (countOfRecords - 1) : 0
        
        for (index, record) in records.enumerated() {
            if record.dateString != dateString || index == lastIndex {
                dateString = record.dateString
                groupedByDates.append(rows)
                rows = []
            }
            rows.append(record)
        }
        
        // Limit to two days
        let groupedRecords: [[Record]]
        if groupedByDates.count > 2 {
            groupedRecords = Array(groupedByDates[0..<2])
        } else {
            groupedRecords = groupedByDates
        }
        
        // Prepare response
        for day in groupedRecords {
            
            // Date of the day
            if let firstRecord = day.first {
                if let recordDate = Date.serverDate(from: firstRecord.dateString)?.humanReadable {
                    schedule +=  twoLines + "🗓  " + recordDate + newLine
                }
            }
            
            for record in day {
                
                // Pair
                if !record.pairName.isEmpty {
                    schedule += twoLines + record.pairName + ":"
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
