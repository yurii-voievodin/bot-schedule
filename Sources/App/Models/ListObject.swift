//
//  ListObject.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 25.06.17.
//
//

import Vapor
import FluentProvider

class ListObject: Entity {
    let storage = Storage()
    
    // MARK: - Types
    
    enum Field {
        
        case serverID
        case name
        case updatedAt
        case lowercaseName
        
        var name: String {
            switch self {
            case .lowercaseName:
                return "lowercase_name"
            case .name:
                return "name"
            case .serverID:
                return "server_id"
            case .updatedAt:
                return "updated_at"
            }
        }
    }
    
    // MARK: Properties
    
    var serverID: Int
    var name: String
    var updatedAt: String
    var lowercaseName: String
    
    // MARK: Fluent Serialization
    
    /// Initializes the ListObject from the
    /// database row
    required init(row: Row) throws {
        serverID = try row.get(ListObject.Field.serverID.name)
        name = try row.get(ListObject.Field.name.name)
        updatedAt = try row.get(ListObject.Field.updatedAt.name)
        lowercaseName = try row.get(ListObject.Field.lowercaseName.name)
    }
    
    /// Serializes the ListObject to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(ListObject.Field.serverID.name, serverID)
        try row.set(ListObject.Field.name.name, name)
        try row.set(ListObject.Field.updatedAt.name, updatedAt)
        try row.set(ListObject.Field.lowercaseName.name, lowercaseName)
        return row
    }
}
