//
//  GroupController.swift
//  App
//
//  Created by Yura Voevodin on 01.10.17.
//

import Vapor
import HTTP

/// RESTful interactions with Groups table
final class GroupController: ResourceRepresentable {
    typealias Model = Group
    
    // MARK: - Properties
    
    let client: ClientFactoryProtocol
    
    // MARK: - Initialization
    
    init(drop: Droplet) throws {
        client = try drop.config.resolveClient()
    }
    
    // MARK: - Methods
    
    /// When users call 'GET' on '/groups'
    /// it should return an index of all available groups
    func index(_ req: Request) throws -> ResponseRepresentable {
        let records = try Model.all().makeJSON()
        var json = JSON()
        try json.set("groups", records)
        return json
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/groups/1' we should show that specific group
    func show(_ req: Request, group: Model) throws -> ResponseRepresentable {
        
        // Check of need to update Grop
        let currentHour = Date().dateWithHour
        if group.updatedAt != currentHour {
            // Try to delete old records
            try group.records.delete()
            
            // Try to import schedule
            try ScheduleImportManager.importSchedule(for: .group, id: group.serverID, client: client)
            
            // Update date in object
            group.updatedAt = currentHour
            try group.save()
        }
        
        // Fetch sorted records for Group.
        let records = try group.records
            .sort("date", .ascending)
            .sort("pair_name", .ascending)
            .all()
        
        var json = JSON()
        try json.set("group", group)
        try json.set("group.records", records)
        return json
    }
    
    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<Model> {
        return Resource(
            index: index,
            show: show
        )
    }
}
