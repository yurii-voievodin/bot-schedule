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
    
    static func show(for message: String, chat: [String : Any]?, client: ClientFactoryProtocol) throws -> String {
        // Get ID of group from message (/group_{id})
        let idString = message.substring(from: message.index(message.startIndex, offsetBy: 7))
        guard let id = Int(idString) else { return "" }
        
        // Find records for groups
        guard let group = try Group.makeQuery().filter(Field.serverID.name, id).first() else { return "" }
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
        
        // Formatting a response
        var response = Record.prepareResponse(for: records)
        response += twoLines +  "👥 Група - " + group.name
        return response
    }
}
