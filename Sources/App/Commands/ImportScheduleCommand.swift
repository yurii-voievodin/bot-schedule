//
//  ImportScheduleCommand.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 11.02.17.
//
//

import Vapor
import Console
import HTTP
import Kanna

final class ImportScheduleCommand: Command {

    // MARK: - Constants

    public let id = "ImportSchedule"
    public let help = [""]
    public let console: ConsoleProtocol

    // MARK: - Variables

    fileprivate var droplet: Droplet?

    // MARK: - Initialization

    public init(console: ConsoleProtocol, droplet: Droplet) {
        self.console = console
        self.droplet = droplet
    }

    // MARK: - Public interface

    public func run(arguments: [String]) throws {

        // TODO: Fetch data about groups, teachers and auditoriums from database

        // TODO: Generate parameters for POST request

        // TODO: Fetch data about about single group, teacher and auditorium in loop

        // TODO: Save all to database

        _ = try drop.client.post("http://schedule.sumdu.edu.ua/index/json")
    }
}
