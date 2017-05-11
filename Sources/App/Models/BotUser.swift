//
//  BotUser.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 02.04.17.
//
//

import Vapor
import Fluent
import Foundation

final class BotUser: Model {
    
    // MARK: Properties
    
    var id: Node?
    var exists: Bool = false
    
    var chatID: Int
    var firstName: String?
    var lastName: String?
    var requests: Int
    
    // MARK: - Initialization
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        chatID = try node.extract("chat_id")
        firstName = try node.extract("first_name")
        lastName = try node.extract("last_name")
        requests = try node.extract("requests")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "chat_id": chatID,
            "first_name": firstName,
            "last_name": lastName,
            "requests": requests
            ])
    }
    
    init?(_ object: [String: Polymorphic]) {
        guard let chatID = object["id"]?.int else { return nil }
        self.chatID = chatID
        self.firstName = object["first_name"]?.string
        self.lastName = object["last_name"]?.string
        self.requests = 0
    }
}

// MARK: - Preparation

extension BotUser: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(entity, closure: { user in
            user.id()
            user.int("chat_id")
            user.string("first_name", optional: true)
            user.string("last_name", optional: true)
            user.int("requests")
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

// MARK: - Relationships

extension BotUser {
    
    func historyRecords() throws -> Children<HistoryRecord> {
        return children()
    }
}

// MARK: - Requests

extension BotUser {
    
    static func registerRequest(for chat: [String : Polymorphic], objectID: Node, type: ObjectType) {
        guard var user = BotUser(chat) else { return }
        do {
            // Try to find user and add new if not found
            if var existingUser = try BotUser.query().filter("chat_id", .equals, user.chatID).first() {
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
    
    static func registerRequest(for chat: [String : Polymorphic]?) {
        guard let chat = chat else { return }
        guard var user = BotUser(chat) else { return }
        do {
            // Try to find user and add new if not found
            if var existingUser = try BotUser.query().filter("chat_id", .equals, user.chatID).first() {
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
    
    func updateHistory(objectID: Node, type: ObjectType) {
        guard let userID = id else { return }
        
        // Check count of history records
        if let historyRecords = try? self.historyRecords().all() {
            if historyRecords.count == 5, let lastRecord = historyRecords.first {
                try? lastRecord.delete()
            }
        }
        switch type {
        case .auditorium:
            do {
                if try HistoryRecord.query().filter("auditorium_id", .equals, objectID).first() == nil {
                    var newHistoryRecord = HistoryRecord(auditoriumID: objectID, userID: userID)
                    try newHistoryRecord.save()
                }
            } catch  {
                print(error)
            }
        case .group:
            do {
                if try HistoryRecord.query().filter("group_id", .equals, objectID).first() == nil {
                    var newHistoryRecord = HistoryRecord(groupID: objectID, userID: userID)
                    try newHistoryRecord.save()
                }
            } catch  {
                print(error)
            }
        case .teacher:
            do {
                if try HistoryRecord.query().filter("teacher_id", .equals, objectID).first() == nil {
                    var newHistoryRecord = HistoryRecord(teacherID: objectID, userID: userID)
                    try newHistoryRecord.save()
                }
            } catch  {
                print(error)
            }
        }
    }
}
