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
struct ImportCommand: Command {
    
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
            return try importAuditoriums(using: context)
        case "groups":
//            try importGroups()
            return .done(on: context.container)
        case "teachers":
//            try importTeachers()
            return .done(on: context.container)
        default:
            return .done(on: context.container)
        }
    }
}

// MARK: - Functions of import

extension ImportCommand {
    
    /// Import auditoriums from SumDU API
    ///
    /// - Throws: ImportError
    private func importAuditoriums(using context: CommandContext) throws -> EventLoopFuture<Void> {
        let methodAuditoriums = "?method=getAuditoriums"
        let futureResponse = try fetchData(using: context, for: methodAuditoriums)
        let result = futureResponse.do { (response) in
            Auditorium.importFrom(response.http.body.data)
        }
        let voidResponse = result.map(to: Void.self) { _ in }
        return voidResponse
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
    
    private func fetchData(using context: CommandContext, for method: String) throws -> EventLoopFuture<Response> {
        // Preparations
        let terminal = try context.container.make(Terminal.self)
        let loadingBar = terminal.loadingBar(title: "Loading")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let client = FoundationClient(session, on: context.container)
        _ = loadingBar.start(on: context.container)
        // Make request
        let baseURL = "http://schedule.sumdu.edu.ua/index/json"
        let futureResponse = client.get(baseURL + method)
        futureResponse.always {
            loadingBar.succeed()
        }
        // Response
        return futureResponse
    }
}

