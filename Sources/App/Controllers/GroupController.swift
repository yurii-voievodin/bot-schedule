//
//  GroupController.swift
//  App
//
//  Created by Yura Voevodin on 01.10.17.
//

import Vapor

/// Here we have a controller that helps facilitate
/// RESTful interactions with our Groups table
final class GroupController {
    typealias Model = Group
    
    // MARK: - Methods
    
    /// When users call 'GET' on '/groups'
    /// it should return an index of all available groups
    func index(_ request: Request) throws -> Future<[Model]> {
        let groups = Model.query(on: request).all()
        return groups
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/groups/1' we should show that specific group
//    func show(_ request: Request, group: Model) throws -> Future<Model> {
//
//        // Check of need to update Group
//        let currentHour = Date().dateWithHour
//        if group.updatedAt != currentHour {
//            // Try to delete old records
//            try group.records.delete()
//
//            // Try to import schedule
////            try ScheduleImportManager.importSchedule(for: .group, id: group.serverID, client: client)
//
//            // Update date in object
//            group.updatedAt = currentHour
//            _ = group.save(on: request)
//        }
    
        // Fetch sorted records for Group.
//        let records = try group.records
//            .sort("date", .ascending)
//            .sort("pair_name", .ascending)
//            .all()
//
//        var json = JSON()
//        try json.set("group", group)
//        try json.set("group.records", records)
//        return json
//    }
}
