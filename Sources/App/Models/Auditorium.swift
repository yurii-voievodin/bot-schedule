//
//  Auditorium.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 15.04.17.
//
//

import Vapor
import Fluent
import Foundation

final class Auditorium: Typable {
    
    // MARK: Properties
    
    var id: Node?
    var exists: Bool = false
    
    var serverID: Int
    var name: String
    var updatedAt: String
    var lowercaseName: String
    
    // MARK: Initialization
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        serverID = try node.extract(TypableFields.serverID.name)
        name = try node.extract(TypableFields.name.name)
        updatedAt = try node.extract(TypableFields.updatedAt.name)
        lowercaseName = try node.extract(TypableFields.lowercaseName.name)
    }
    
    init?(array: [String : Any]) {
        guard let serverID = array[TypableFields.serverID.name] as? Int else { return nil }
        self.serverID = serverID
        
        guard let name = array[TypableFields.name.name] as? String else { return nil }
        self.name = name
        
        guard let updatedAt = array[TypableFields.updatedAt.name] as? String else { return nil }
        self.updatedAt = updatedAt
        
        guard let lowercaseName = array[TypableFields.lowercaseName.name] as? String else { return nil }
        self.lowercaseName = lowercaseName
    }
    
    // MARK: - Node
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            TypableFields.serverID.name: serverID,
            TypableFields.name.name: name,
            TypableFields.updatedAt.name: updatedAt,
            TypableFields.lowercaseName.name: lowercaseName
            ]
        )
    }
}

// MARK: - Helpers

extension Auditorium {
    
    static func find(by name: String) throws -> String {
        guard name.characters.count > 2 else { return "" }
        var response = ""
        let auditoriums = try Auditorium.query().filter(TypableFields.lowercaseName.name, contains: name.lowercased()).all()
        for auditorium in auditoriums {
            response += auditorium.name + " - " + ObjectType.auditorium.prefix + "\(auditorium.serverID)" + newLine
        }
        guard response.characters.count > 0 else { return "" }
        return twoLines + "🚪 Аудиторії:" + twoLines + response
    }
    
    static func show(for message: String, chat: [String : Polymorphic]?) throws -> String {
        // Get ID of auditorium from message (/auditorium_{id})
        let idString = message.substring(from: message.index(message.startIndex, offsetBy: 12))
        guard let id = Int(idString) else { return "" }
        
        // Find records for auditorium
        guard var auditorium = try Auditorium.query().filter(TypableFields.serverID.name, id).first() else { return "" }
        let currentHour = Date().dateWithHour
        if auditorium.updatedAt != currentHour {
            // Try to delete old records
            try auditorium.records().delete()
            
            // Try to import schedule
            try ScheduleImportManager.importSchedule(for: .auditorium, id: auditorium.serverID)
            
            // Update date in object
            auditorium.updatedAt = currentHour
            try auditorium.save()
        }
        
        // Register request for user
        if let chat = chat, let id = auditorium.id {
            BotUser.registerRequest(for: chat, objectID: id, type: .auditorium)
        }
        
        let records = try auditorium.records()
            .sort("date", .ascending)
            .sort("pair_name", .ascending)
            .all()
        
        // Formatting a response
        var response = Record.prepareResponse(for: records)
        response += twoLines +  "🚪 Аудиторія - " + auditorium.name
        return response
    }
}

// MARK: - Relationships

extension Auditorium {
    
    func records() throws -> Children<Record> {
        return children()
    }
}

// MARK: - Preparation

extension Auditorium: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(entity, closure: { object in
            object.id()
            object.int(TypableFields.serverID.name)
            object.string(TypableFields.name.name)
            object.string(TypableFields.updatedAt.name)
            object.string(TypableFields.lowercaseName.name)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}
