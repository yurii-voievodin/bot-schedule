//
//  Group.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 15.04.17.
//
//

import Vapor
import FluentProvider

final class Group: Model, ListObject {
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

// MARK: JSON
// How the model converts from / to JSON.
extension Group: JSONConvertible {
    
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
// This allows Group models to be returned
// directly in route closures
extension Group: ResponseRepresentable { }

// MARK: - Relationships

extension Group {
    var records: Children<Group, Record> {
        return children()
    }
}

// MARK: - Preparation

extension Group: Preparation {
    
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

extension Group {
    
    static func find(by name: String) throws -> [InlineKeyboardButton] {
        guard name.characters.count > 3 else { return [] }
        var response: [InlineKeyboardButton] = []
        let groups = try Group.makeQuery().filter(Field.lowercaseName.name, .contains, name.lowercased()).all()
        let prefix = ObjectType.group.prefix
        for group in groups {
            let button = InlineKeyboardButton(text: group.name, callbackData: prefix + "\(group.serverID)")
            response.append(button)
        }
        return response
    }
    
    static func find(by name: String) throws -> [Button] {
        guard name.characters.count > 3 else { return [] }
        var buttons: [Button] = []
        let groups = try Group.makeQuery().filter(Field.lowercaseName.name, .contains, name.lowercased()).all()
        for group in groups {
            let payload = ObjectType.group.prefix + "\(group.serverID)"
            let auditoriumButton = try Button(type: .postback, title: group.name, payload: payload)
            buttons.append(auditoriumButton)
        }
        return buttons
    }
    
    static func show(for message: String, chat: [String : Node]? = nil, client: ClientFactoryProtocol) throws -> [String] {
        // Get ID of group from message (/group_{id})
        let idString = message.substring(from: message.index(message.startIndex, offsetBy: 7))
        guard let id = Int(idString) else { return [] }
        
        // Find records for groups
        guard let group = try Group.makeQuery().filter(Field.serverID.name, id).first() else { return [] }
        let currentHour = Date().dateWithHour
        if group.updatedAt != currentHour {
            // Try to delete old records
            try group.records.delete()
            
            // Try to import schedule
            try ScheduleImportManager.importSchedule(for: .group, id: group.serverID, client: client)
            
            // Update date in object
            group.updatedAt = currentHour
            try group.save()
        }
        
        // Register request for user
        if let chat = chat, let id = group.id {
            BotUser.registerRequest(for: chat, objectID: id, type: .group)
        }
        
        let records = try group.records
            .sort("date", .ascending)
            .sort("pair_name", .ascending)
            .all()
        
        return Record.prepareResponse(for: records)
    }
}
