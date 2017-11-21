//
//  GroupController.swift
//  App
//
//  Created by Yura Voevodin on 01.10.17.
//

import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// RESTful interactions with our Groups table
final class GroupController: ResourceRepresentable {
    typealias Model = Group
    
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
        
        // TODO: Send request to schedule.sumdu.edu.ua
        
        let records = try group.records.all()
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

/// Since GroupController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension GroupController: EmptyInitializable { }
