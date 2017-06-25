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
    
    // MARK: Properties
    
    var serverID: Int
    var name: String
    var updatedAt: String
    var lowercaseName: String
    
    // MARK: Fluent Serialization
    
    /// Initializes the Auditorium from the
    /// database row
    required init(row: Row) throws {
        serverID = try row.get(TypableFields.serverID.name)
        name = try row.get(TypableFields.name.name)
        updatedAt = try row.get(TypableFields.updatedAt.name)
        lowercaseName = try row.get(TypableFields.lowercaseName.name)
    }
    
    /// Serializes the Auditorium to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(TypableFields.serverID.name, serverID)
        try row.set(TypableFields.name.name, name)
        try row.set(TypableFields.updatedAt.name, updatedAt)
        try row.set(TypableFields.lowercaseName.name, lowercaseName)
        return row
    }
}
