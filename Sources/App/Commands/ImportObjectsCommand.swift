//
//  ImportObjectsCommand.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 11.02.17.
//
//

import Vapor
import Console
import HTTP
import Kanna

fileprivate typealias Data = [String: String]

final class ImportObjectsCommand: Command {

    // MARK: - Constants

    public let id = "importObjects"
    public let help = ["This command does import data of groups, auditoriums, teachers from http://schedule.sumdu.edu.ua"]
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
        // Request to server with schedule
        let response = try drop.client.get("http://schedule.sumdu.edu.ua")
        guard let bodyBytes = response.body.bytes else { return }
        guard let htmlString = String(bytes: bodyBytes, encoding: .windowsCP1251) else { return }
        guard let document = HTML(html: htmlString, encoding: .windowsCP1251) else { return }

        // Extract data from HTML
        let groups = extractData(with: "select#group", from: document)
        let auditoriums = extractData(with: "select#auditorium", from: document)
        let teachers = extractData(with: "select#teacher", from: document)

        // Append to the single dictionary
        var allObjects: Data = [:]
        allObjects = appendData(previous: allObjects, new: groups)
        allObjects = appendData(previous: allObjects, new: auditoriums)
        allObjects = appendData(previous: allObjects, new: teachers)

        // Import all data to database
        ObjectImportManager().importFromArray(array: allObjects)
    }
}

// MARK: - Helpers

extension ImportObjectsCommand {

    /// Append data to the dictionary
    ///
    /// - Parameters:
    ///   - previousData: previous
    ///   - newData: new
    /// - Returns: previous with new
    fileprivate func appendData(previous previousData: Data, new newData: Data) -> Data {
        var updatedData: Data = previousData
        for object in newData {
            if object.key.characters.count > 0 && object.value.characters.count > 0 && object.value != "0" {
                updatedData[object.key] = object.value
            }
        }
        return updatedData
    }

    /// Fetch data about groups, auditoriums, teachers
    ///
    /// - Parameters:
    ///   - selector: selector for "select" HTML attribute
    ///   - document: document to fetch data
    /// - Returns: array of data - name: id
    fileprivate func extractData(with selector: String, from document: HTMLDocument) -> Data {
        var data: Data = [:]

        for option in document.css(selector) {
            for value in option.css("option") {
                if let name = value.content, let id = value["value"] {
                    data[name] = id
                }
            }
        }
        return data
    }
}
