//
//  TestCommand.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 17.08.17.
//
//

import FluentPostgreSQL
import Vapor

/// Console command for test a bot
final class TestCommand: Command {
    
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
        return ["This command test a bot"]
    }
    
    func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        // TODO: Finish this command
    }
}

// MARK: - Methods

extension TestCommand {
    
    fileprivate func run(command: String?) {
//        guard let command = command else { return }
//        guard let botCommand = BotCommand(rawValue: command) else { return }
//        console.print(botCommand.response, newLine: true)
    }
    
    fileprivate func search(_ request: String?) throws {
        guard let request = request else { return }
        
        let auditoriumButtons: [InlineKeyboardButton] = try Auditorium.find(by: request)
        let groupButtons: [InlineKeyboardButton] = try Group.find(by: request)
        let teacherButtons: [InlineKeyboardButton] = try Teacher.find(by: request)
        
        print(auditoriumButtons)
        print(groupButtons)
        print(teacherButtons)
    }
    
    fileprivate func show(_ request: String?) throws {
//        guard let request = request else { return }
//        do {
//            let result: [String]
//            if request.hasPrefix(ObjectType.auditorium.prefix) {
//                result = try Auditorium.show(for: request, chatID: nil, client: client)
//            } else if request.hasPrefix(ObjectType.group.prefix) {
//                result = try Group.show(for: request, chatID: nil, client: client)
//            } else if request.hasPrefix(ObjectType.teacher.prefix) {
//                result = try Teacher.show(for: request, chatID: nil, client: client)
//            } else {
//                result = ["Empty"]
//            }
//            print(result)
//        } catch {
//            print(error)
//        }
    }
}
