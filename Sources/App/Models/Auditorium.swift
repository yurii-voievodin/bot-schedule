//
//  Auditorium.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 15.04.17.
//
//

import Vapor
import FluentProvider

final class Auditorium: Model, ListObject {
    let storage = Storage()
    
    // MARK: Properties
    
    var serverID: Int
    var name: String
    var updatedAt: String
    var lowercaseName: String
    
    // MARK: - Initialization
    
    init(serverID: Int, name: String, updatedAt: String, lowercaseName: String) {
        self.serverID = serverID
        self.name = name
        self.updatedAt = updatedAt
        self.lowercaseName = lowercaseName
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the ListObject from the
    /// database row
    required init(row: Row) throws {
        serverID = try row.get(Field.serverID.name)
        name = try row.get(Field.name.name)
        updatedAt = try row.get(Field.updatedAt.name)
        lowercaseName = try row.get(Field.lowercaseName.name)
    }
    
    /// Serializes the ListObject to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Field.serverID.name, serverID)
        try row.set(Field.name.name, name)
        try row.set(Field.updatedAt.name, updatedAt)
        try row.set(Field.lowercaseName.name, lowercaseName)
        return row
    }
}

// MARK: - Relationships

extension Auditorium {
    var records: Children<Auditorium, Record> {
        return children()
    }
}

// MARK: JSON
// How the model converts from / to JSON.
extension Auditorium: JSONConvertible {
    
    convenience init(json: JSON) throws {
        try self.init(
            serverID: json.get(Field.serverID.name),
            name: json.get(Field.name.name),
            updatedAt: json.get(Field.updatedAt.name),
            lowercaseName: json.get(Field.lowercaseName.name)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set(Field.name.name, name)
        return json
    }
}

// MARK: HTTP
// This allows Auditorium models to be returned
// directly in route closures
extension Auditorium: ResponseRepresentable { }

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
    static func find(by name: String?) throws -> [InlineKeyboardButton] {
        guard let name = name else { return [] }
        guard name.count > 3 else { return [] }
        var response: [InlineKeyboardButton] = []
        let auditoriums = try Auditorium.makeQuery().filter(Field.lowercaseName.name, .contains, name.lowercased()).all()
        let prefix = ObjectType.auditorium.prefix
        for auditorium in auditoriums {
            let button = InlineKeyboardButton(text: auditorium.name, callbackData: prefix + "\(auditorium.serverID)")
            response.append(button)
        }
        return response
    }
    
    static func find(by name: String) throws -> [Button] {
        guard name.count > 3 else { return [] }
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
    static func show(for message: String, chatID: Int? = nil, client: ClientFactoryProtocol) throws -> [String] {
        // Get ID of auditorium from message (/auditorium_{id})
        let idString = message[message.index(message.startIndex, offsetBy: 12)...]
        guard let id = Int(idString) else { return [] }
        
        // Find records for auditorium
        guard let auditorium = try Auditorium.makeQuery().filter(Field.serverID.name, id).first() else { return [] }
        let currentHour = Date().dateWithHour
        
        if auditorium.updatedAt != currentHour {
            // Delete old records
            try auditorium.records.delete()
            
            // Import new schedule
            try ScheduleImportManager.importSchedule(for: .auditorium, id: auditorium.serverID, client: client)
            
            // Update date
            auditorium.updatedAt = currentHour
            try auditorium.save()
        }
        
        // Register request for user
        if let chatID = chatID, let id = auditorium.id {
            BotUser.registerRequest(chatID: chatID, objectID: id, type: .auditorium)
        }
        
        let records = try auditorium.records
            .sort("date", .ascending)
            .sort("pair_name", .ascending)
            .all()
        
        return try Record.prepareResponse(for: records)
    }
}
