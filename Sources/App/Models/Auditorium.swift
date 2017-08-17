//
//  Auditorium.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 15.04.17.
//
//

import Vapor
import FluentProvider

final class Auditorium: ListObject {
    
}

// MARK: - Relationships

extension Auditorium {
    var records: Children<Auditorium, Record> {
        return children()
    }
}

// MARK: - Preparation

extension Auditorium: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { object in
            object.id()
            object.int(Field.serverID.name)
            object.string(Field.name.name)
            object.string(Field.updatedAt.name)
            object.string(Field.lowercaseName.name)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - Helpers

extension Auditorium {
    
    /// Find by name
    static func find(by name: String) throws -> String {
        guard name.characters.count > 2 else { return "" }
        var response = ""
        let auditoriums = try Auditorium.makeQuery().filter(Field.lowercaseName.name, .contains, name.lowercased()).all()
        for auditorium in auditoriums {
            response += auditorium.name + " - " + ObjectType.auditorium.prefix + "\(auditorium.serverID)" + newLine
        }
        guard response.characters.count > 0 else { return "" }
        return twoLines + "🚪 Аудиторії:" + twoLines + response
    }
    
    /// Schedule for Auditorium
    static func show(for message: String, chat: [String : Any]?, client: ClientFactoryProtocol) throws -> String {
        // Get ID of auditorium from message (/auditorium_{id})
        let idString = message.substring(from: message.index(message.startIndex, offsetBy: 12))
        guard let id = Int(idString) else { return "" }
        
        // Find records for auditorium
        guard let auditorium = try Auditorium.makeQuery().filter(Field.serverID.name, id).first() else { return "" }
        let currentHour = Date().dateWithHour
        
        if auditorium.updatedAt != currentHour {
            
            // Try to delete old records
            try auditorium.records.delete()
            
            // Try to import schedule
            try ScheduleImportManager.importSchedule(for: .auditorium, id: auditorium.serverID, client: client)
            
            // Update date in object
            auditorium.updatedAt = currentHour
            try auditorium.save()
        }
        
        // Register request for user
        if let chat = chat, let id = auditorium.id {
            BotUser.registerRequest(for: chat, objectID: id, type: .auditorium)
        }
        
        let records = try auditorium.records
            .sort("date", .ascending)
            .sort("pair_name", .ascending)
            .all()
        
        // Formatting a response
        var response = Record.prepareResponse(for: records)
        response += twoLines +  "🚪 Аудиторія - " + auditorium.name
        return response
    }
}
