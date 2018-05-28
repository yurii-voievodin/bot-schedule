//
//  ImportManager.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 15.04.17.
//
//

import Vapor
import FluentPostgreSQL

class ImportManager<Type: ListObject> {
    
//    func importFrom(_ json: [String: JSON]) throws {
//        for item in json {
//            
//            // Get ID and name
//            guard let id = Int(item.key) else { continue }
//            guard let name = item.value.string else { continue }
//            
//            // Validation
//            guard name.count > 0 && id != 0 else { continue }
//            
//            if let existingObject = try Type.makeQuery().filter(Field.serverID.name, id).first() {
//                // Find existing
//                existingObject.name = name
//                existingObject.updatedAt = ""
//                existingObject.lowercaseName = existingObject.name.lowercased()
//                try existingObject.save()
//            } else {
//                // Or create a new one
//                var row = Row()
//                try row.set(Field.serverID.name, id)
//                try row.set(Field.name.name, name)
//                try row.set(Field.updatedAt.name, "")
//                try row.set(Field.lowercaseName.name, name.lowercased())
//                
//                // Save
//                let newObject = try Type(row: row)
//                try newObject.save()
//            }
//        }
//    }
}
