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
//import Kanna
import Foundation
import Rainbow

final class ImportCommand: Command {

    /// Import errors
    enum ImportError: Swift.Error {
        case missingArguments
        case unknownArgument
    }

    /// Arguments for this command
    enum Argument: String {
        case objects = "objects"
    }

    // MARK: - Constants

    public let id = "import"
    public let help = ["This command imports data about groups, auditoriums, teachers from http://schedule.sumdu.edu.ua \n Arguments: \n objects - import all objects (roups, auditoriums, teachers)"]
    public let console: ConsoleProtocol

    // MARK: - Variables

    fileprivate var droplet: Droplet?

    // MARK: - Initialization

    public init(console: ConsoleProtocol, droplet: Droplet) {
        self.console = console
        self.droplet = droplet
    }

    // MARK: - Lifecycle

    public func run(arguments: [String]) throws {
//        guard let firstArgument = arguments.first else { throw ImportError.missingArguments }
//        guard let argument = Argument(rawValue: firstArgument) else { throw ImportError.unknownArgument }
//
//        switch argument {
//        case .objects:
//            try importObjects()
//        }
    }
}

// MARK: - Import objetcs

// TODO: Turn on when issue with Kanna will be fixed https://github.com/tid-kijyun/Kanna/issues/142

extension ImportCommand {

    /// Extract data from HTML <select> attribute
    ///
    /// - Parameters:
    ///   - selector: selector for "select" HTML attribute
    ///   - document: document to fetch data
    /// - Returns: array of data - name: id
//    fileprivate func extractData(with selector: String, from document: HTMLDocument) -> Dictionary<String, Any> {
//        var data: Dictionary = [String: Any]()
//
//        for option in document.css(selector) {
//            for value in option.css("option") {
//                guard let name = value.content, let id = value["value"] else { continue }
//                data[name] = id
//            }
//        }
//        return data
//    }

//    fileprivate func importObjects() throws {
//        // Request to server with schedule
//        let response = try drop.client.get("http://schedule.sumdu.edu.ua")
//        guard let bodyBytes = response.body.bytes else { return }
//        guard let htmlString = String(bytes: bodyBytes, encoding: .windowsCP1251) else { return }
//        guard let document = HTML(html: htmlString, encoding: .windowsCP1251) else { return }
//
//        // Extract data from HTML
//        let groups = extractData(with: "select#group", from: document)
//        let auditoriums = extractData(with: "select#auditorium", from: document)
//        let teachers = extractData(with: "select#teacher", from: document)
//
//        // Import all data to database
//        try ObjectsImportManager.importFrom(groups, for: .group)
//        try ObjectsImportManager.importFrom(auditoriums, for: .auditorium)
//        try ObjectsImportManager.importFrom(teachers, for: .teacher)
//
//        // Success
//        let count = try Object.all().count
//        print("\(count) objects imported".green)
//    }
}
