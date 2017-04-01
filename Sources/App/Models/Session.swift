//
//  Session.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 12.03.17.
//
//

import Vapor
import Fluent
import Foundation

final class Session: Model {

    // MARK: Properties

    var id: Node?
    var exists: Bool = false

    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var requests: Int

    // MARK: Initialization

    init(year: Int, month: Int, day: Int, hour: Int, requests: Int) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.requests = requests
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        year = try node.extract("year")
        month = try node.extract("month")
        day = try node.extract("day")
        hour = try node.extract("hour")
        requests = try node.extract("requests")
    }

    // MARK: Node

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "year": year,
            "month": month,
            "day": day,
            "hour": hour,
            "requests": requests
            ])
    }
}

// MARK: - Preparation

extension Session: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(entity, closure: { session in
            session.id()
            session.int("year")
            session.int("month")
            session.int("day")
            session.int("hour")
            session.int("requests")
        })
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

// MARK: - Statistics

extension Session {

    static func statisticsForToday() -> String {
        var results = 0
        guard let (year, month, day, _) = Date().intDate else {
            return "0"
        }
        do {
            let sessions = try Session.query()
                .filter("year", .equals, year)
                .filter("month", .equals, month)
                .filter("day", .equals, day)
                .all()
            for session in sessions {
                results += session.requests
            }
        } catch {
            print(error.localizedDescription)
            return "0"
        }
        return String(results)
    }

    static func statisticsForMonth() -> String {
        var results = 0
        guard let (year, month, _, _) = Date().intDate else {
            return "0"
        }
        do {
            let sessions = try Session.query()
                .filter("year", .equals, year)
                .filter("month", .equals, month)
                .all()
            for session in sessions {
                results += session.requests
            }
        } catch {
            print(error.localizedDescription)
            return "0"
        }
        return String(results)
    }
}
