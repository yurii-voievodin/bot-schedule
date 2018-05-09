//
//  ImportCommand.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 25.02.17.
//
//

import FluentPostgreSQL
import Vapor

/// Console command for import auditoriums, groups and teachers from SumDU API
final class ImportCommand: Command {
    
    /// See `Command`
    var arguments: [CommandArgument] {
        return [.argument(name: "type")]
    }
    
    /// See `Command`.
    public var options: [CommandOption] {
        return []
    }
    
    /// See `Command`
    var help: [String] {
        return ["This command imports data about groups, auditoriums, teachers from http://schedule.sumdu.edu.ua"]
    }
    
    func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        let type = try context.argument("type")
        
        switch type {
        case "auditoriums":
            try importAuditoriums()
        case "groups":
            try importGroups()
        case "teachers":
            try importTeachers()
        default:
            break
        }
        return .done(on: context.container)
    }
}

// MARK: - Functions of import

extension ImportCommand {
    
    /// Import auditoriums from SumDU API
    ///
    /// - Throws: ImportError
    private func importAuditoriums() throws {
//        let methodAuditoriums = "?method=getAuditoriums"
//        let json = try fetchData(for: methodAuditoriums)
//        let importManager = ImportManager<Auditorium>()
//        try importManager.importFrom(json)
//        // Success
//
//        let count = try Auditorium.all().count
//        print("\(count) auditoriums imported")
    }
    
    /// Import groups from SumDU API
    ///
    /// - Throws: ImportError
    private func importGroups() throws {
//        let methodGroups = "?method=getGroups"
//        let json = try fetchData(for: methodGroups)
//        let importManager = ImportManager<Group>()
//        try importManager.importFrom(json)
//        // Success
//        let count = try Group.all().count
//        print("\(count) groups imported")
    }
    
    /// Import teachers from SumDU API
    ///
    /// - Throws: ImportError
    private func importTeachers() throws {
//        let methodTeachers = "?method=getTeachers"
//        let json = try fetchData(for: methodTeachers)
//        let importManager = ImportManager<Teacher>()
//        try importManager.importFrom(json)
//        // Success
//        let count = try Teacher.all().count
//        print("\(count) teachers imported")
    }
    
//    private func fetchData(for method: String) throws -> [String: JSON] {
//        let baseURL = "http://schedule.sumdu.edu.ua/index/json"
//        let response = try client.get(baseURL + method)
//        guard let json = response.json else { throw ImportError.missingData }
//        guard let array = json.object else { throw ImportError.missingData }
//        return array
//    }
}
