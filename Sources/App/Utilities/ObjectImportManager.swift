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

    func importFromArray(array: [String: String]) {
        // Save new and update existing records
        for object in array {
            guard let serverID = Int(object.value) else { continue }
            createOrUpdate(with: serverID, name: object.key)
        }
    }

    fileprivate func createOrUpdate(with id: Int, name: String) {
        do {
            if var object = try Object.query().filter("serverid", id).first() {
                // Find existing
                object.name = name
                try object.save()
            } else {
                // Or create a new one
                var newObject = Object(serverID: id, name: name)
                try newObject.save()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
