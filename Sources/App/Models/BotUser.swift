//
//  BotUser.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 02.04.17.
//
//

import Vapor
import FluentProvider

final class BotUser: Model {
    let storage = Storage()
    
    // MARK: Properties
    
    var chatID: Int
    var requests: Int
    
    // MARK: - Initialization
    
    init?(_ object: [String: Any]) {
        guard let chatID = object["id"] as? Int else { return nil }
        self.chatID = chatID
        self.requests = 0
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the BotUser from the
    /// database row
    init(row: Row) throws {
        chatID = try row.get("chat_id")
        requests = try row.get("requests")
    }
    
    /// Serializes the BotUser to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("chat_id", chatID)
        try row.set("requests", requests)
        return row
    }
}

// MARK: - Preparation

extension BotUser: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { user in
            user.id()
            user.int("chat_id")
            user.int("requests")
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - Relationships

extension BotUser {
    var historyRecords: Children<BotUser, HistoryRecord> {
        return children()
    }
}

// MARK: - Requests

extension BotUser {
    
    static func registerRequest(for chat: [String : Any], objectID: Identifier, type: ObjectType) {
        guard let user = BotUser(chat) else { return }
        do {
            // Try to find user and add new if not found
            if let existingUser = try BotUser.makeQuery().filter("chat_id", .equals, user.chatID).first() {
                existingUser.requests += 1
                try existingUser.save()
                existingUser.updateHistory(objectID: objectID, type: type)
            } else {
                user.requests = 1
                try user.save()
                user.updateHistory(objectID: objectID, type: type)
            }
        } catch {
            print(error)
        }
    }
    
    static func registerRequest(for chat: [String : Any]?) {
        guard let chat = chat else { return }
        guard let user = BotUser(chat) else { return }
        do {
            // Try to find user and add new if not found
            if let existingUser = try BotUser.makeQuery().filter("chat_id", .equals, user.chatID).first() {
                existingUser.requests += 1
                try existingUser.save()
            } else {
                user.requests = 1
                try user.save()
            }
        } catch {
            print(error)
        }
    }
}

// MARK: - History

extension BotUser {
    
    func updateHistory(objectID: Identifier, type: ObjectType) {
        guard let userID = id else { return }
        switch type {
        case .auditorium:
            do {
                if try HistoryRecord.makeQuery().filter("auditorium_id", .equals, objectID).first() == nil {
                    
                    // Delete one record if count == 5
                    checkCountOfHistoryRecords()
                    
                    // Save new record
                    let newHistoryRecord = HistoryRecord(auditoriumID: objectID, userID: userID)
                    try newHistoryRecord.save()
                }
            } catch  {
                print(error)
            }
        case .group:
            do {
                if try HistoryRecord.makeQuery().filter("group_id", .equals, objectID).first() == nil {
                    
                    // Delete one record if count == 5
                    checkCountOfHistoryRecords()
                    
                    // Save new record
                    let newHistoryRecord = HistoryRecord(groupID: objectID, userID: userID)
                    try newHistoryRecord.save()
                }
            } catch  {
                print(error)
            }
        case .teacher:
            do {
                if try HistoryRecord.makeQuery().filter("teacher_id", .equals, objectID).first() == nil {
                    
                    // Delete one record if count == 5
                    checkCountOfHistoryRecords()
                    
                    // Save new record
                    let newHistoryRecord = HistoryRecord(teacherID: objectID, userID: userID)
                    try newHistoryRecord.save()
                }
            } catch  {
                print(error)
            }
        }
    }
    
    fileprivate func checkCountOfHistoryRecords() {
        // Check count of history records
        if let historyRecords = try? self.historyRecords.all() {
            if historyRecords.count == 5, let lastRecord = historyRecords.first {
                try? lastRecord.delete()
            }
        }
    }
}
