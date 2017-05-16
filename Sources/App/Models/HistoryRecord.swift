//
//  HistoryRecord.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 03.05.17.
//
//

import Vapor
import Fluent
import Foundation

final class HistoryRecord: Entity {
    
    // MARK: - Properties
    
    var id: Node?
    var exists: Bool = false
    
    var auditoriumID: Node?
    var groupID: Node?
    var teacherID: Node?
    var userID: Node
    
    // MARK: - Initialization
    
    init(auditoriumID: Node, userID: Node) {
        self.auditoriumID = auditoriumID
        self.userID = userID
    }
    
    init(groupID: Node, userID: Node) {
        self.groupID = groupID
        self.userID = userID
    }
    
    init(teacherID: Node, userID: Node) {
        self.teacherID = teacherID
        self.userID = userID
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        
        // Relationships
        auditoriumID = try node.extract("auditorium_id")
        groupID = try node.extract("group_id")
        teacherID = try node.extract("teacher_id")
        userID = try node.extract("botuser_id")
    }
    
    // MARK: - Node
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "auditorium_id": auditoriumID,
            "group_id": groupID,
            "teacher_id": teacherID,
            "botuser_id": userID
            ]
        )
    }
}

// MARK: - Relationships

extension HistoryRecord {
    
    func user() throws -> Parent<BotUser> {
        return try parent(userID)
    }
    
    func auditorium() throws -> Parent<Auditorium>? {
        if let id = auditoriumID {
            return try parent(id)
        } else {
            return nil
        }
    }
    
    func group() throws -> Parent<Group>? {
        if let id = groupID {
            return try parent(id)
        } else {
            return nil
        }
    }
    
    func teacher() throws -> Parent<Teacher>? {
        if let id = teacherID {
            return try parent(id)
        } else {
            return nil
        }
    }
}

// MARK: - Preparation

extension HistoryRecord: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(entity, closure: { creator in
            creator.id()
            creator.parent(Auditorium.self, optional: true)
            creator.parent(Group.self, optional: true)
            creator.parent(Teacher.self, optional: true)
            creator.parent(BotUser.self)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

// MARK: - User history

extension HistoryRecord {
    
    static func history(for chatID: Int) -> String {
        let emptyHistory = "Історія порожня"
        var history = ""
        do {
            let user = try BotUser.query().filter("chat_id", chatID).first()
            guard let records = try user?.historyRecords().all() else { return emptyHistory }
            for record in records {
                // Auditorium
                if let auditorium = try record.auditorium()?.get() {
                    history += newLine + "🚪 " + auditorium.name + " - " + ObjectType.auditorium.prefix + "\(auditorium.serverID)"
                }
                // Group
                if let group = try record.group()?.get() {
                    history += newLine + "👥 " + group.name + " - " + ObjectType.group.prefix + "\(group.serverID)"
                }
                // Teacher
                if let teacher = try record.teacher()?.get() {
                    history += newLine + "👔 " + teacher.name + " - " + ObjectType.teacher.prefix + "\(teacher.serverID)"
                }
            }
        } catch {
            print(error)
        }
        if history.isEmpty {
            return emptyHistory
        } else {
            return "Історія запитів" + newLine + history
        }
    }
}
