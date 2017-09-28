//
//  TestCommand.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 17.08.17.
//
//

import Vapor
import Console
import HTTP
import Foundation

/// Console command for test a bot
final class TestCommand: Command, ConfigInitializable {
    
    // MARK: - Enums
    
    /// Arguments for this command
    enum Argument: String {
        case command = "command"
        case search = "search"
        case show = "show"
    }
    
    /// Test errors
    enum TestError: Swift.Error {
        case missingArguments
        case unknownArgument
    }
    
    // MARK: - Properties
    
    let id = "test"
    let help = ["This command test a bot"]
    var console: ConsoleProtocol
    var client: ClientFactoryProtocol
    
    // MARK: - Methods
    
    required init(config: Config) throws {
        console = try config.resolveConsole()
        client = try config.resolveClient()
    }
    
    public func run(arguments: [String]) throws {
        guard let firstArgument = arguments.first else { throw TestError.missingArguments }
        guard let argument = Argument(rawValue: firstArgument) else { throw TestError.unknownArgument }
        let lastArgument = arguments.last
        
        switch argument {
        case .command:
            run(command: lastArgument)
            
        case .search:
            try search(lastArgument)
            
        case .show:
            try show(lastArgument)
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func run(command: String?) {
        guard let command = command else { return }
        guard let botCommand = BotCommand(rawValue: command) else { return }
        console.print(botCommand.response, newLine: true)
    }
    
    fileprivate func search(_ request: String?) throws {
        guard let request = request else { return }
        var searchResults = ""
        searchResults += try Auditorium.find(by: request)
        searchResults += try Group.find(by: request)
        searchResults += try Teacher.find(by: request)
        
        print("results = ", searchResults)
    }
    
    fileprivate func show(_ request: String?) throws {
        guard let request = request else { return }
        
        let result: [String]
        if request.hasPrefix(ObjectType.auditorium.prefix) {
            result = try Auditorium.show(for: request, client: client)
            
        } else if request.hasPrefix(ObjectType.group.prefix) {
            result = try Group.show(for: request, chat: [:], client: client)
            
        } else if request.hasPrefix(ObjectType.teacher.prefix) {
            result = try Teacher.show(for: request, chat: [:], client: client)
        } else {
            result = ["Empty"]
        }
        print(result)
    }
}
