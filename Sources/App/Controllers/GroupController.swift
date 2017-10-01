//
//  GroupController.swift
//  App
//
//  Created by Yura Voevodin on 01.10.17.
//

import Vapor
import HTTP

final class GroupController: ResourceRepresentable {
    typealias Model = Group
    
    /// When users call 'GET' on '/groups'
    /// it should return an index of all available groups
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Group.all().makeJSON()
    }
    
    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<Model> {
        return Resource(
            index: index
        )
    }
}

/// Since GroupController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension GroupController: EmptyInitializable { }
