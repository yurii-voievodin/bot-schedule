//
//  AuditoriumController.swift
//  App
//
//  Created by Yura Voevodin on 11/11/18.
//

import Vapor
import HTTP

/// RESTful interactions with Auditorium table
final class AuditoriumController: ResourceRepresentable {
    typealias Model = Auditorium

    // MARK: - Properties
    
    let client: ClientFactoryProtocol
    
    // MARK: - Initialization
    
    init(drop: Droplet) throws {
        client = try drop.config.resolveClient()
    }
    
    // MARK: - Methods
    
    /// When users call 'GET' on '/auditoriums'
    /// it should return an index of all available groups
    func index(_ req: Request) throws -> ResponseRepresentable {
        let records = try Model.all().makeJSON()
        var json = JSON()
        try json.set("auditoriums", records)
        return json
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/auditoriums/1' we should show that specific group
    func show(_ req: Request, auditorium: Model) throws -> ResponseRepresentable {
        
        // Check of need to update Grop
        let currentHour = Date().dateWithHour
        if auditorium.updatedAt != currentHour {
            // Try to delete old records
            try auditorium.records.delete()
            
            // Try to import schedule
            try ScheduleImportManager.importSchedule(for: .auditorium, id: auditorium.serverID, client: client)
            
            // Update date in object
            auditorium.updatedAt = currentHour
            try auditorium.save()
        }
        
        // Fetch sorted records for Auditorium.
        let records = try auditorium.records
            .sort("date", .ascending)
            .sort("pair_name", .ascending)
            .all()
        
        var json = JSON()
        try json.set("auditorium", auditorium)
        try json.set("auditorium.records", records)
        return json
    }
    
    func makeResource() -> Resource<Model> {
        return Resource(
            index: index,
            show: show
        )
    }
}
