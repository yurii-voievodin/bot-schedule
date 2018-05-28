//
//  Group.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 15.04.17.
//
//

import FluentPostgreSQL
import Vapor

final class Group: ListObject {
    
    // MARK: Properties
    
    var id: Int?
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
}

// MARK: - Relationships

//extension Group {
//    var records: Children<Group, Record> {
//        return children()
//    }
//}

// MARK: - Helpers

extension Group {
    
//    static func find(by name: String?) throws -> [InlineKeyboardButton] {
//        guard let name = name else { return [] }
//        guard name.count > 3 else { return [] }
//        var response: [InlineKeyboardButton] = []
//        let groups = try Group.makeQuery().filter(Field.lowercaseName.name, .contains, name.lowercased()).all()
//        let prefix = ObjectType.group.prefix
//        for group in groups {
//            let button = InlineKeyboardButton(text: group.name, callbackData: prefix + "\(group.serverID)")
//            response.append(button)
//        }
//        return response
//    }
//    
//    static func find(by name: String) throws -> [Button] {
//        guard name.count > 3 else { return [] }
//        var buttons: [Button] = []
//        let groups = try Group.makeQuery().filter(Field.lowercaseName.name, .contains, name.lowercased()).all()
//        for group in groups {
//            let payload = ObjectType.group.prefix + "\(group.serverID)"
//            let auditoriumButton = try Button(type: .postback, title: group.name, payload: payload)
//            buttons.append(auditoriumButton)
//        }
//        return buttons
//    }
//    
//    static func show(for message: String, chatID: Int? = nil, client: ClientFactoryProtocol) throws -> [String] {
//        // Get ID of group from message (/group_{id})
//        let idString = message[message.index(message.startIndex, offsetBy: 7)...]
//        guard let id = Int(idString) else { return [] }
//        
//        // Find records for groups
//        guard let group = try Group.makeQuery().filter(Field.serverID.name, id).first() else { return [] }
//        let currentHour = Date().dateWithHour
//        if group.updatedAt != currentHour {
//            // Try to delete old records
//            try group.records.delete()
//            
//            // Try to import schedule
//            try ScheduleImportManager.importSchedule(for: .group, id: group.serverID, client: client)
//            
//            // Update date in object
//            group.updatedAt = currentHour
//            try group.save()
//        }
//        
//        // Register request for user
//        if let chatID = chatID, let id = group.id {
//            BotUser.registerRequest(chatID: chatID, objectID: id, type: .group)
//        }
//        
//        let records = try group.records
//            .sort("date", .ascending)
//            .sort("pair_name", .ascending)
//            .all()
//        
//        return try Record.prepareResponse(for: records)
//    }
}
