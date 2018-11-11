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
    
    func makeResource() -> Resource<Model> {
        return Resource(index: index)
    }
}
