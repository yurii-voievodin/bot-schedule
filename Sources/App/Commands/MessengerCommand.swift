//
//  MessengerCommand.swift
//  App
//
//  Created by Yura Voevodin on 24.09.17.
//

import Vapor
import Console
import HTTP
import Foundation

final class MessengerComand: Command, ConfigInitializable {
    
    // MARK: - Enums
    
    /// Arguments for this command
    enum Argument: String {
        case search = "search"
        case show = "show"
    }
    
    /// Test errors
    enum TestError: Swift.Error {
        case missingArguments
        case unknownArgument
    }
    
    // MARK: - Properties
    
    let id = "messenger"
    let help = ["This command tests a Messenger bot"]
    var console: ConsoleProtocol
    var client: ClientFactoryProtocol
    
    required init(config: Config) throws {
        console = try config.resolveConsole()
        client = try config.resolveClient()
    }
    
    public func run(arguments: [String]) throws {
        guard let firstArgument = arguments.first else { throw TestError.missingArguments }
        guard let argument = Argument(rawValue: firstArgument) else { throw TestError.unknownArgument }
        let lastArgument = arguments.last
        
        switch argument {
        case .search:
            try search(lastArgument)
        case .show:
            try show(lastArgument)
        }
    }
    
    fileprivate func search(_ request: String?) throws {
        guard let request = request else { return }
        
        var searchResults: [Button] = []
        searchResults = try Auditorium.find(by: request)
        
        print(searchResults)
    }
    
    fileprivate func show(_ request: String?) throws {
        guard let request = request else { return }
        
        var result = ""
        if request.hasPrefix(ObjectType.auditorium.prefix) {
            result = try Auditorium.showForTelegram(for: request, client: client)
        }
        print(result)
    }
}
