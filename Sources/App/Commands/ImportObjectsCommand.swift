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
        var allObjects: [ObjectStruct] = []
        allObjects = append(groups, to: allObjects, type: .group)
        allObjects = append(auditoriums, to: allObjects, type: .auditorium)
        allObjects = append(teachers, to: allObjects, type: .teacher)

        // Import all data to database
        ObjectImportManager().importFrom(array: allObjects)
    }
}

// MARK: - Helpers

extension ImportObjectsCommand {

    /// Append data to the dictionary
    ///
    /// - Parameters:
    ///   - newData: new
    ///   - previousData: previous
    ///   - type: ObjectType
    /// - Returns: previous with new
    fileprivate func append(_ newData: Data, to previousData: [ObjectStruct], type: ObjectType) -> [ObjectStruct] {
        var data = previousData
        for object in newData {
            guard object.key.characters.count > 0 && object.value.characters.count > 0 && object.value != "0" else {
                continue
            }
            guard let serverID = Int(object.value) else { continue }
            data.append(ObjectStruct(id: serverID, name: object.key, type: type))
        }
        return data
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
