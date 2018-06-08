//
//  Auditorium.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 15.04.17.
//
//

import FluentPostgreSQL
import Vapor

final class Auditorium: PostgreSQLModel {
    
    // MARK: Properties
    
    var id: Int?
    var serverID: Int
    var name: String
    var updatedAt: String
    var lowercaseName: String
    
    // MARK: - Initialization
    
    init(id: Int? = nil, serverID: Int, name: String, updatedAt: String, lowercaseName: String) {
        self.serverID = serverID
        self.name = name
        self.updatedAt = updatedAt
        self.lowercaseName = lowercaseName
    }
}

/// Allows `Auditorium` to be used as a migration.
extension Auditorium: Migration { }

// MARK: - Relationships

//extension Auditorium {
//    var records: Children<Auditorium, Record> {
//        return children()
//    }
//}

// MARK: - Helpers

extension Auditorium {
    
    static func importFrom(_ data: Data?) {
        guard let data = data else { return }
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            if let dictionary = json as? [String: String] {
                print(dictionary)
                
                for item in dictionary {
                    // Get ID and name
                    guard let id = Int(item.key) else { continue }
                    let name = item.value
                    
                    // Validation
                    guard name.count > 0 && id != 0 else { continue }
                    
                    
                }
            }
        }
    }
    
    /// Find by name
//    static func find(by name: String?) throws -> [InlineKeyboardButton] {
//        guard let name = name else { return [] }
//        guard name.count > 3 else { return [] }
//        var response: [InlineKeyboardButton] = []
//        let auditoriums = try Auditorium.makeQuery().filter(Field.lowercaseName.name, .contains, name.lowercased()).all()
//        let prefix = ObjectType.auditorium.prefix
//        for auditorium in auditoriums {
//            let button = InlineKeyboardButton(text: auditorium.name, callbackData: prefix + "\(auditorium.serverID)")
//            response.append(button)
//        }
//        return response
//    }
    
//    static func find(by name: String) throws -> [Button] {
//        guard name.count > 3 else { return [] }
//        var buttons: [Button] = []
//        let auditoriums = try Auditorium.makeQuery().filter(Field.lowercaseName.name, .contains, name.lowercased()).all()
//        for auditorium in auditoriums {
//            let payload = ObjectType.auditorium.prefix + "\(auditorium.serverID)"
//            let auditoriumButton = try Button(type: .postback, title: auditorium.name, payload: payload)
//            buttons.append(auditoriumButton)
//        }
//        return buttons
//    }
    
    /// Schedule for Auditorium
//    static func show(for message: String, chatID: Int? = nil, client: ClientFactoryProtocol) throws -> [String] {
//        // Get ID of auditorium from message (/auditorium_{id})
//        let idString = message[message.index(message.startIndex, offsetBy: 12)...]
//        guard let id = Int(idString) else { return [] }
//        
//        // Find records for auditorium
//        guard let auditorium = try Auditorium.makeQuery().filter(Field.serverID.name, id).first() else { return [] }
//        let currentHour = Date().dateWithHour
//        
//        if auditorium.updatedAt != currentHour {
//            // Delete old records
//            try auditorium.records.delete()
//            
//            // Import new schedule
//            try ScheduleImportManager.importSchedule(for: .auditorium, id: auditorium.serverID, client: client)
//            
//            // Update date
//            auditorium.updatedAt = currentHour
//            try auditorium.save()
//        }
//        
//        // Register request for user
//        if let chatID = chatID, let id = auditorium.id {
//            BotUser.registerRequest(chatID: chatID, objectID: id, type: .auditorium)
//        }
//        
//        let records = try auditorium.records
//            .sort("date", .ascending)
//            .sort("pair_name", .ascending)
//            .all()
//        
//        return try Record.prepareResponse(for: records)
//    }
}
