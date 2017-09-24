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
        guard name.characters.count > 3 else { return "" }
        var response = ""
        let auditoriums = try Auditorium.makeQuery().filter(Field.lowercaseName.name, .contains, name.lowercased()).all()
        for auditorium in auditoriums {
            response += auditorium.name + " - " + ObjectType.auditorium.prefix + "\(auditorium.serverID)" + newLine
        }
        guard response.characters.count > 0 else { return "" }
        return twoLines + "🚪 Аудиторії:" + twoLines + response
    }
    
    static func find(by name: String) throws -> [Button] {
        guard name.characters.count > 3 else { return [] }
        var buttons: [Button] = []
        let auditoriums = try Auditorium.makeQuery().filter(Field.lowercaseName.name, .contains, name.lowercased()).all()
        for auditorium in auditoriums {
            let payload = ObjectType.auditorium.prefix + "\(auditorium.serverID)"
            let auditoriumButton = try Button(type: .postback, title: auditorium.name, payload: payload)
            buttons.append(auditoriumButton)
        }
        return buttons
    }
    
    /// Schedule for Auditorium
    static func showForMessenger(for message: String, client: ClientFactoryProtocol, chat: [String : Node]? = nil) throws -> [String] {
        // Get ID of auditorium from message (/auditorium_{id})
        let idString = message.substring(from: message.index(message.startIndex, offsetBy: 12))
        guard let id = Int(idString) else { return [] }
        
        // Find records for auditorium
        guard let auditorium = try Auditorium.makeQuery().filter(Field.serverID.name, id).first() else { return [] }
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
        
        return Record.prepareMessengerResponse(for: records)
    }
    
    static func showForTelegram(for message: String, client: ClientFactoryProtocol, chat: [String : Node]? = nil) throws -> String {
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
        var response = Record.prepareTelegramResponse(for: records)
        response += twoLines +  "🚪 Аудиторія - " + auditorium.name
        return response
    }
}
