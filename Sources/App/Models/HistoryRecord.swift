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
    
    var userID: Node
    var objectType: Int
    var objectID: Int
    
    // MARK: - Initialization
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        
        // Properties
        objectType = try node.extract("object_type")
        objectID = try node.extract("object_id")
        
        // Relationships
        userID = try node.extract("user_id")
    }
    
    // MARK: - Node
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "user_id": userID,
            "object_type": objectType,
            "object_id": objectID
            ]
        )
    }
}

// MARK: - Preparation

extension HistoryRecord: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(entity, closure: { creator in
            creator.id()
            creator.parent(BotUser.self)
            creator.int("object_type")
            creator.int("object_id")
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}
