//
//  ImportManager.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 21.02.17.
//
//

import Vapor
import Fluent

/// For import objects from JSON
final class ObjectImportManager {

    // MARK: - Public interface

    func importFrom(array: [ObjectStruct]) {
        // Save new and update existing records
        for object in array {
            createOrUpdate(object)
        }
    }

    fileprivate func createOrUpdate(_ objectStruct: ObjectStruct) {
        do {
            if var object = try Object.query().filter("serverid", objectStruct.id).first() {
                // Find existing
                object.name = objectStruct.name
                object.type = objectStruct.type.rawValue
                try object.save()
            } else {
                // Or create a new one
                var newObject = Object(serverID: objectStruct.id, name: objectStruct.name, type: objectStruct.type.rawValue)
                try newObject.save()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
