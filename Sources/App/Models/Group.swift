//
//  Group.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 15.04.17.
//
//

import Vapor
import FluentProvider

final class Group: ListObject {

}

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
    
    static func find(by name: String) throws -> String {
        guard name.characters.count > 3 else { return "" }
        var response = ""
        let groups = try Group.makeQuery().filter(Field.lowercaseName.name, .contains, name.lowercased()).all()
        for group in groups {
            response += group.name + " - " + ObjectType.group.prefix + "\(group.serverID)" + newLine
        }
        guard response.characters.count > 0 else { return "" }
        return twoLines + "👥 Групи:" + twoLines + response
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
