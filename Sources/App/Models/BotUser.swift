//
//  BotUser.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 02.04.17.
//
//

import Vapor
import FluentPostgreSQL

final class BotUser: Model {
    static var idKey: IDKey = \.id
    
    typealias Database = PostgreSQLDatabase
    
    typealias ID = Int
    
    
    // MARK: Properties
    
    var id: Int?
    var chatID: Int
    var requests: Int
    
    // MARK: - Initialization
    
    init(chatID: Int) {
        self.chatID = chatID
        self.requests = 0
    }
}

// MARK: - Relationships

//extension BotUser {
//    var historyRecords: Children<BotUser, HistoryRecord> {
//        return children()
//    }
//}

// MARK: - Requests

extension BotUser {
    
//    static func registerRequest(chatID: Int, objectID: Identifier, type: ObjectType) {
//        let user = BotUser(chatID: chatID)
//        do {
//            // Try to find user and add new if not found
//            if let existingUser = try BotUser.makeQuery().filter("chat_id", .equals, user.chatID).first() {
//                existingUser.requests += 1
//                try existingUser.save()
//                existingUser.updateHistory(objectID: objectID, type: type)
//            } else {
//                user.requests = 1
//                try user.save()
//                user.updateHistory(objectID: objectID, type: type)
//            }
//        } catch {
//            print(error)
//        }
//    }
    
//    static func registerRequest(chatID: Int?) {
//        guard let id = chatID else { return }
//        let user = BotUser(chatID: id)
//        do {
//            // Try to find user and add new if not found
//            if let existingUser = try BotUser.makeQuery().filter("chat_id", .equals, user.chatID).first() {
//                existingUser.requests += 1
//                try existingUser.save()
//            } else {
//                user.requests = 1
//                try user.save()
//            }
//        } catch {
//            print(error)
//        }
//    }
}

// MARK: - History

extension BotUser {
    
//    func updateHistory(objectID: Identifier, type: ObjectType) {
//        guard let userID = id else { return }
//        switch type {
//        case .auditorium:
//            do {
//                if try HistoryRecord.makeQuery().filter("auditorium_id", .equals, objectID).first() == nil {
//
//                    // Delete one record if count == 5
//                    checkCountOfHistoryRecords()
//
//                    // Save new record
//                    let newHistoryRecord = HistoryRecord(auditoriumID: objectID, userID: userID)
//                    try newHistoryRecord.save()
//                }
//            } catch  {
//                print(error)
//            }
//        case .group:
//            do {
//                if try HistoryRecord.makeQuery().filter("group_id", .equals, objectID).first() == nil {
//
//                    // Delete one record if count == 5
//                    checkCountOfHistoryRecords()
//
//                    // Save new record
//                    let newHistoryRecord = HistoryRecord(groupID: objectID, userID: userID)
//                    try newHistoryRecord.save()
//                }
//            } catch  {
//                print(error)
//            }
//        case .teacher:
//            do {
//                if try HistoryRecord.makeQuery().filter("teacher_id", .equals, objectID).first() == nil {
//
//                    // Delete one record if count == 5
//                    checkCountOfHistoryRecords()
//
//                    // Save new record
//                    let newHistoryRecord = HistoryRecord(teacherID: objectID, userID: userID)
//                    try newHistoryRecord.save()
//                }
//            } catch  {
//                print(error)
//            }
//        }
//    }
    
    fileprivate func checkCountOfHistoryRecords() {
        // Check count of history records
//        if let historyRecords = try? self.historyRecords.all() {
//            if historyRecords.count == 5, let lastRecord = historyRecords.first {
//                try? lastRecord.delete()
//            }
//        }
    }
}

// MARK: - Count

extension BotUser {
    
    static func countOfUsers() -> String {
        return "0"
//        let count = try? BotUser.count()
//        if let count = count {
//            return "\(count)"
//        } else {
//            return "0"
//        }
    }
}
