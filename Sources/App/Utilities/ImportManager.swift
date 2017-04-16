//
//  ImportManager.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 15.04.17.
//
//

import Vapor
import Fluent
import Foundation

class ImportManager<Type: Typable> {

    func importFrom(_ array: [(String, Polymorphic)]) throws {
        for item in array {

            // Get ID and name
            guard let id = item.0.int else { continue }
            guard let name = item.1.string else { continue }

            // Validation
            guard name.characters.count > 0 && id != 0 else { continue }

            if var existingObject = try Type.query().filter(TypableFields.serverID.name, id).first() {
                // Find existing
                existingObject.name = name
                existingObject.updatedAt = ""
                existingObject.lowercaseName = existingObject.name.lowercased()
                try existingObject.save()
            } else {
                // Or create a new one
                let array: [String : Any] = [
                    TypableFields.serverID.name: id,
                    TypableFields.name.name: name,
                    TypableFields.updatedAt.name: "",
                    TypableFields.lowercaseName.name: name.lowercased()
                ]
                var newObject = Type(array: array)
                try newObject?.save()
            }
        }
    }
}

// MARK: - Typable

protocol Typable: Model {

    // MARK: Default properties

    var serverID: Int { get set }
    var name: String { get set }
    var updatedAt: String { get set }
    var lowercaseName: String { get set }

    // MARK: - Initialization

    init?(array: [String : Any])
}

// MARK: - TypableFields

enum TypableFields {
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
