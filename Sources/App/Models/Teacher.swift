//
//  Teacher.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 15.04.17.
//
//

import Vapor
import FluentProvider

final class Teacher: Typable {
    let storage = Storage()
    
    // MARK: Properties
    
    var serverID: Int
    var name: String
    var updatedAt: String
    var lowercaseName: String
    
    // MARK: Fluent Serialization
    
    /// Initializes the Teacher from the
    /// database row
    init(row: Row) throws {
        serverID = try row.get(TypableFields.serverID.name)
        name = try row.get(TypableFields.name.name)
        updatedAt = try row.get(TypableFields.updatedAt.name)
        lowercaseName = try row.get(TypableFields.lowercaseName.name)
    }
    
    /// Serializes the Teacher to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(TypableFields.serverID.name, serverID)
        try row.set(TypableFields.name.name, name)
        try row.set(TypableFields.updatedAt.name, updatedAt)
        try row.set(TypableFields.lowercaseName.name, lowercaseName)
        return row
    }
}

// MARK: - Relationships

extension Teacher {
    var records: Children<Teacher, Record> {
        return children()
    }
}

// MARK: - Preparation

extension Teacher: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { object in
            object.id()
            object.int(TypableFields.serverID.name)
            object.string(TypableFields.name.name)
            object.string(TypableFields.updatedAt.name)
            object.string(TypableFields.lowercaseName.name)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - Helpers

extension Teacher {
    
    static func find(by name: String) throws -> String {
        var response = ""
        guard name.characters.count > 2 else { return response }
        
        let teachers = try Teacher.makeQuery().filter(TypableFields.lowercaseName.name, .contains, name.lowercased()).all()
        for teacher in teachers {
            response += teacher.name + " - /teacher_\(teacher.serverID)" + newLine
        }
        guard !response.isEmpty else { return "" }
        return twoLines + "👔 Викладачі:" + twoLines + response
    }
    
    static func show(for message: String, chat: [String : Any]?) throws -> String {
        // Get ID of teacher from message (/teacher_{id})
        let idString = message.substring(from: message.index(message.startIndex, offsetBy: 9))
        guard let id = Int(idString) else { return "" }
        
        // Find records for teachers
        guard var teacher = try Teacher.makeQuery().filter(TypableFields.serverID.name, id).first() else { return "" }
        let currentHour = Date().dateWithHour
        if teacher.updatedAt != currentHour {
            // Try to delete old records
            try teacher.records.delete()
            
            // Try to import schedule
            try ScheduleImportManager.importSchedule(for: .teacher, id: teacher.serverID)
            
            // Update date in object
            teacher.updatedAt = currentHour
            try teacher.save()
        }
        
        // Register request for user
        if let chat = chat, let id = teacher.id {
            BotUser.registerRequest(for: chat, objectID: id, type: .teacher)
        }
        
        let records = try teacher.records
            .sort("date", .ascending)
            .sort("pair_name", .ascending)
            .all()
        
        // Formatting a response
        var response = Record.prepareResponse(for: records)
        response += twoLines +  "👔 Викладач - " + teacher.name
        return response
    }
}
