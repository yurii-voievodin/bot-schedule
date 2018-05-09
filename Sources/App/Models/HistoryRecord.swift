//
//  HistoryRecord.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 03.05.17.
//
//

import Vapor
import FluentPostgreSQL

final class HistoryRecord: Entity {
    let storage = Storage()
    
    // MARK: Properties
    
    var auditoriumID: Identifier?
    var groupID: Identifier?
    var teacherID: Identifier?
    var userID: Identifier
    
    // MARK: - Initialization
    
    init(auditoriumID: Identifier, userID: Identifier) {
        self.auditoriumID = auditoriumID
        self.userID = userID
    }
    
    init(groupID: Identifier, userID: Identifier) {
        self.groupID = groupID
        self.userID = userID
    }
    
    init(teacherID: Identifier, userID: Identifier) {
        self.teacherID = teacherID
        self.userID = userID
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the HistoryRecord from the
    /// database row
    init(row: Row) throws {
        auditoriumID = try row.get("auditorium_id")
        groupID = try row.get("group_id")
        teacherID = try row.get("teacher_id")
        userID = try row.get("bot_user_id")
    }
    
    /// Serializes the HistoryRecord to the database
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set("auditorium_id", auditoriumID)
        try row.set("group_id", groupID)
        try row.set("teacher_id", teacherID)
        try row.set("bot_user_id", userID)
        
        return row
    }
}

// MARK: - Relationships

extension HistoryRecord {
    
    var user: Parent<HistoryRecord, BotUser> {
        return parent(id: userID)
    }
    
    var auditorium: Parent<HistoryRecord, Auditorium>? {
        if let id = auditoriumID {
            return parent(id: id)
        } else {
            return nil
        }
    }
    
    var group: Parent<HistoryRecord, Group>? {
        if let id = groupID {
            return parent(id: id)
        } else {
            return nil
        }
    }
    
    var teacher: Parent<HistoryRecord, Teacher>? {
        if let id = teacherID {
            return parent(id: id)
        } else {
            return nil
        }
    }
}

// MARK: - Preparation

extension HistoryRecord: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { creator in
            creator.id()
            creator.parent(Auditorium.self, optional: true)
            creator.parent(Group.self, optional: true)
            creator.parent(Teacher.self, optional: true)
            creator.parent(BotUser.self)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - User history

extension HistoryRecord {
    
    static func history(for chatID: Int) -> [InlineKeyboardButton] {
        var response: [InlineKeyboardButton] = []
        do {
            let user = try BotUser.makeQuery().filter("chat_id", chatID).first()
            guard let records = try user?.historyRecords.all() else { return [] }
            for record in records {
                // Auditorium
                if let auditorium = try record.auditorium?.get() {
                    let text = "🚪 " + auditorium.name
                    let callback = ObjectType.auditorium.prefix + "\(auditorium.serverID)"
                    let button = InlineKeyboardButton(text: text, callbackData: callback)
                    response.append(button)
                }
                // Group
                if let group = try record.group?.get() {
                    let text = "👥 " + group.name
                    let callback = ObjectType.group.prefix + "\(group.serverID)"
                    let button = InlineKeyboardButton(text: text, callbackData: callback)
                    response.append(button)
                }
                // Teacher
                if let teacher = try record.teacher?.get() {
                    let text = "👔 " + teacher.name
                    let callback = ObjectType.teacher.prefix + "\(teacher.serverID)"
                    let button = InlineKeyboardButton(text: text, callbackData: callback)
                    response.append(button)
                }
            }
        } catch {
            print(error)
        }
        return response
    }
}
