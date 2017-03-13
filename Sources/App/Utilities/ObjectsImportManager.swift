//
//  ObjectsImportManager.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 13.03.17.
//
//

import Vapor
import Foundation

struct ObjectsImportManager {

    static func importFrom(_ data: Dictionary<String, Any>, for type: Object.ObjectType) throws {
        for object in data {
            // Get ID and name
            guard let id = object.value as? String else { continue }
            let name = object.key

            // Validation
            guard name.characters.count > 0 && id.characters.count > 0 && id != "0" else { continue }
            guard let serverID = Int(id) else { continue }

            if var existingObject = try Object.query().filter("server_id", serverID).first() {
                // Find existing
                existingObject.name = name
                existingObject.type = type.rawValue
                existingObject.updatedAt = ""
                existingObject.lowercaseName = existingObject.name.lowercased()
                try existingObject.save()
            } else {
                // Or create a new one
                let array: [String : Any] = [
                    "server_id": serverID,
                    "name": name,
                    "type": type.rawValue,
                    "updated_at": "",
                    "lowercase_name": name.lowercased()
                ]
                var newObject = Object(array: array)
                try newObject?.save()
            }
        }
    }
}
