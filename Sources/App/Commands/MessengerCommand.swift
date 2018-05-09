//
//  MessengerCommand.swift
//  App
//
//  Created by Yura Voevodin on 24.09.17.
//

import Vapor

final class MessengerComand: Command {
    
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
        return ["This command tests a Messenger bot"]
    }
    
    func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        let type = try context.argument("type")
        
        // TODO: Finish this command
        
        context.console.print(type, newLine: true)
        
        return .done(on: context.container)
    }
    
    /// Create a new `BootCommand`.
    public init() { }
}

// MARK: - Methods

extension MessengerComand {
    
    private func search(_ request: String?) throws {
//        guard let request = request else { return }
//
//        var searchResults: [Button] = []
//        searchResults = try Auditorium.find(by: request)
//
//        print(searchResults)
    }
    
    private func show(_ request: String?) throws {
//        guard let request = request else { return }
//
//        var result: [String] = []
//        if request.hasPrefix(ObjectType.auditorium.prefix) {
//            result = try Auditorium.show(for: request, client: client)
//        }
//        print(result)
    }
}
