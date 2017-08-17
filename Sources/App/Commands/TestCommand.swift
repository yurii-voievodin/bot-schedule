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
    
    // MARK: - Methods
    
    required init(config: Config) throws {
        console = try config.resolveConsole()
    }
    
    public func run(arguments: [String]) throws {
        guard let firstArgument = arguments.first else { throw TestError.missingArguments }
        guard let argument = Argument(rawValue: firstArgument) else { throw TestError.unknownArgument }
        
        switch argument {
        case .command:
            run(command: arguments.last)
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func run(command: String?) {
        guard let command = command else { return }
        guard let botCommand = BotCommand(rawValue: command) else { return }
        console.print(botCommand.response, newLine: true)
    }
}
