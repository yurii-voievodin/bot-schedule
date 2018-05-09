//
//  Session.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 12.03.17.
//
//

import Vapor
import FluentPostgreSQL

final class Session: Model {
    let storage = Storage()
    
    // MARK: Properties
    
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
    
    // MARK: Fluent Serialization
    
    /// Initializes the Session from the
    /// database row
    init(row: Row) throws {
        day = try row.get("day")
        month = try row.get("month")
        year = try row.get("year")
        requests = try row.get("requests")
    }
    
    /// Serializes the Session to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("day", day)
        try row.set("month", month)
        try row.set("year", year)
        try row.set("requests", requests)
        return row
    }
}

// MARK: - Preparation

extension Session: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { session in
            session.id()
            session.int("day")
            session.int("month")
            session.int("year")
            session.int("requests")
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - Statistics

extension Session {
    
    static func statisticsForToday() -> String {
        var results = 0
        guard let (day, month, year) = Date().calendarComponents else { return "0" }
        do {
            let sessions = try Session.makeQuery()
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
            let sessions = try Session.makeQuery()
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
