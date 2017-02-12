//
//  FetchDataCommand.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 11.02.17.
//
//

import Vapor
import Console
import HTTP
import Kanna

final class FetchDataCommand: Command {

    // MARK: - Constants

    public let id = "fetchData"
    public let help = ["This command does fetches data about groups, auditoriums, teachers from http://schedule.sumdu.edu.ua"]
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
        let response = try drop.client.get("http://schedule.sumdu.edu.ua")
        guard let bodyBytes = response.body.bytes else { return }
        guard let htmlString = String(bytes: bodyBytes, encoding: .windowsCP1251) else { return }
        guard let document = HTML(html: htmlString, encoding: .windowsCP1251) else { return }

        let groups = fetchDataFromSelect("select#group", document: document)
        let auditoriums = fetchDataFromSelect("select#auditorium", document: document)
        let teachers = fetchDataFromSelect("select#teacher", document: document)

        // TODO: Save to database
    }

    // MARK: - Helpers


    /// Fetch data about groups, auditoriums, teachers
    ///
    /// - Parameters:
    ///   - selector: selector for "select" HTML attribute
    ///   - document: document to fetch data
    /// - Returns: array of data - name: id
    fileprivate func fetchDataFromSelect(_ selector: String, document: HTMLDocument) -> [String: String] {
        var data: [String: String] = [:]
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
