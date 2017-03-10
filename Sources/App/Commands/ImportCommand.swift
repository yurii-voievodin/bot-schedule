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
import Kanna
import Foundation

fileprivate typealias Data = [String: String]

final class ImportCommand: Command {

    enum Argument: String {
        case objects = "objects"
        case schedule = "schedule"
    }

    // MARK: - Constants

    public let id = "import"
    public let help = ["This command imports data about schedule, groups, auditoriums, teachers from http://schedule.sumdu.edu.ua"]
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
        guard let firstArgument = arguments.first else { return }
        guard let argument = Argument(rawValue: firstArgument) else { return }

        switch argument {
        case .objects:
            try importObjects()
        case .schedule:
            try importSchedule()
        }
    }
}

// MARK: - Import objetcs

extension ImportCommand {

    /// Extract data from HTML <select> attribute
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

    /// Make array of Node from array of Data
    ///
    /// - Parameter data: input array of Data
    /// - Returns: Output array of Node
    fileprivate func makeNodes(from data: Data, type: ObjectType) throws -> [Node] {
        var nodes: [Node] = []

        for object in data {
            // Get ID and name
            let id = object.value
            let name = object.key

            // Validation
            guard name.characters.count > 0 && id.characters.count > 0 && id != "0" else {
                continue
            }

            let node = try Node( node: [
                "serverid": id,
                "name": name,
                "type": "\(type.rawValue)"
                ])
            nodes.append(node)
        }
        return nodes
    }

    fileprivate func importObjects() throws {
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
        var allNodes: [Node] = []
        allNodes.append(contentsOf: try makeNodes(from: groups, type: .group))
        allNodes.append(contentsOf: try makeNodes(from: auditoriums, type: .auditorium))
        allNodes.append(contentsOf: try makeNodes(from: teachers, type: .teacher))

        // Import all data to database
        try Object.importFrom(nodes: allNodes)
    }
}

// MARK: - Import schedule

extension ImportCommand {

    /// Import errors
    enum ImportError: Swift.Error {
        case failedGetArray
        case missingObjectID
    }

    /// Make request of schedule for object
    ///
    /// - Parameter object: for which get schedule
    /// - Returns: schedule as json
    fileprivate func makeRequestOfSchedule(for object: Object) throws -> Response {
        // Detect type of object
        guard let type = ObjectType(rawValue: object.type) else {
            print("❌ Failed to detect type of object")
            return Response()
        }
        var groupId = "0"
        var teacherId = "0"
        var auditoriumId = "0"
        switch type {
        case .auditorium:
            auditoriumId = String(object.serverID)
        case .group:
            groupId = String(object.serverID)
        case .teacher:
            teacherId = String(object.serverID)
        }

        // Time interval for request
        let startDate = Date()
        let oneDay: TimeInterval = 60*60*24*7
        let endDate = startDate.addingTimeInterval(oneDay)

        // Query parameters
        let query: [String: CustomStringConvertible] = [
            "data[DATE_BEG]": startDate.serverDateFormat,
            "data[DATE_END]": endDate.serverDateFormat,
            "data[KOD_GROUP]": groupId,
            "data[ID_FIO]": teacherId,
            "data[ID_AUD]": auditoriumId
        ]
        return try drop.client.post("http://schedule.sumdu.edu.ua/index/json", query: query)
    }

    /// Imports schedule from "schedule.sumdu.edu.ua" to database
    fileprivate func importSchedule() throws {
        // Generate random IDs
        var IDs: [Int] = []
        let allObjects = try Object.all()
        let objectsCount = allObjects.count
        for _ in 0...100 {
            let randomID = generateRandom(with: objectsCount)
            let randomServerID = allObjects[Int(randomID)].serverID
            IDs.append(randomServerID)
        }

        // Fetch objects
        let objects = try Object.query().filter("serverid", .in, IDs).run()

        for object in objects {
            // Make request and node from JSON response
            let scheduleResponse = try makeRequestOfSchedule(for: object)
            guard let responseArray = scheduleResponse.json?.array else { throw ImportError.failedGetArray }

            // Id of related object
            guard let objectID = object.id else { throw ImportError.missingObjectID }

            // Try to delete old records
            try object.records().delete()
            
            // Try to import new records
            try ScheduleRecord.importFrom(responseArray, for: objectID)
        }
    }

    fileprivate func generateRandom(with max: Int) -> Int {
        #if os(Linux)
            return Int(random() % (max + 1))
        #else
            return Int(arc4random_uniform(UInt32(max)))
        #endif
    }
}
