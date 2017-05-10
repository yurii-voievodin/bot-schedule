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
    
    var day: Int
    var month: Int
    var year: Int
    var requests: Int
    
    // MARK: Initialization
    
    init(day: Int, month: Int, year: Int, requests: Int) {
        self.day = day
        self.month = month
        self.year = year
        self.requests = requests
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        day = try node.extract("day")
        month = try node.extract("month")
        year = try node.extract("year")
        requests = try node.extract("requests")
    }
    
    // MARK: Node
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "day": day,
            "month": month,
            "year": year,
            "requests": requests
            ]
        )
    }
}

// MARK: - Preparation

extension Session: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(entity, closure: { session in
            session.id()
            session.int("day")
            session.int("month")
            session.int("year")
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
        guard let (day, month, year) = Date().calendarComponents else { return "0" }
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
            return "0"
        }
        return String(results)
    }
    
    static func statisticsForMonth() -> String {
        var results = 0
        guard let (_, month, year) = Date().calendarComponents else { return "0" }
        do {
            let sessions = try Session.query()
                .filter("year", .equals, year)
                .filter("month", .equals, month)
                .all()
            for session in sessions {
                results += session.requests
            }
        } catch {
            return "0"
        }
        return String(results)
    }
}
