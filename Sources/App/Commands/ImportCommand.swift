//
//  ImportCommand.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 25.02.17.
//
//

import Vapor
import Console
import HTTP
import Foundation
import Rainbow

/// Console command for import auditoriums, groups and teachers from SumDU API
final class ImportCommand: Command {

    // MARK: - Enums

    /// Arguments for this command
    enum Argument: String {
        case auditoriums = "auditoriums"
        case groups = "groups"
        case teachers = "teachers"
    }

    /// Import errors
    enum ImportError: Swift.Error {
        case missingArguments
        case missingData
        case unknownArgument
    }

    // MARK: - Constants

    public let id = "import"
    public let help = ["This command imports data about groups, auditoriums, teachers from http://schedule.sumdu.edu.ua"]
    public let console: ConsoleProtocol

    fileprivate let baseURL = "http://schedule.sumdu.edu.ua/index/json"
    fileprivate let methodAuditoriums = "?method=getAuditoriums"
    fileprivate let methodGroups = "?method=getGroups"
    fileprivate let methodTeachers = "?method=getTeachers"

    // MARK: - Variables

    fileprivate var droplet: Droplet?

    // MARK: - Initialization

    public init(console: ConsoleProtocol, droplet: Droplet) {
        self.console = console
        self.droplet = droplet
    }

    // MARK: - Run

    public func run(arguments: [String]) throws {
        guard let firstArgument = arguments.first else { throw ImportError.missingArguments }
        guard let argument = Argument(rawValue: firstArgument) else { throw ImportError.unknownArgument }

        switch argument {
        case .auditoriums:
            try importAuditoriums()
        case .groups:
            try importGroups()
        case .teachers:
            try importTeachers()
        }
    }
}

// MARK: - Functions of import

extension ImportCommand {

    /// Import auditoriums from SumDU API
    ///
    /// - Throws: ImportError
    fileprivate func importAuditoriums() throws {
        let data = try fetchData(for: methodAuditoriums)
        let importManager = ImportManager<Auditorium>()
        try importManager.importFrom(data)
        // Success
        let count = try Auditorium.all().count
        print("\(count) auditoriums imported".green)
    }

    /// Import groups from SumDU API
    ///
    /// - Throws: ImportError
    fileprivate func importGroups() throws {
        let data = try fetchData(for: methodGroups)
        let importManager = ImportManager<Group>()
        try importManager.importFrom(data)
        // Success
        let count = try Group.all().count
        print("\(count) groups imported".green)
    }

    /// Import teachers from SumDU API
    ///
    /// - Throws: ImportError
    fileprivate func importTeachers() throws {
        let data = try fetchData(for: methodTeachers)
        let importManager = ImportManager<Teacher>()
        try importManager.importFrom(data)
        // Success
        let count = try Teacher.all().count
        print("\(count) teachers imported".green)
    }

    fileprivate func fetchData(for method: String) throws -> [(String, Polymorphic)] {
        let response = try drop.client.get(baseURL + method)
        guard let json = response.json else { throw ImportError.missingData }
        guard let array = json.object?.allItems else { throw ImportError.missingData }
        return array
    }
}
