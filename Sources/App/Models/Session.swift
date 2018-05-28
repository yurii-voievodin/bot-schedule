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
    typealias Database = PostgreSQLDatabase
    typealias ID = Int
    
    static let idKey: IDKey = \.id
    
    // MARK: Properties
    
    var id: Int?
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
}

// MARK: - Statistics

extension Session {
    
//    static func statisticsForToday() -> String {
//        var results = 0
//        guard let (day, month, year) = Date().calendarComponents else { return "0" }
//        do {
//            let sessions = try Session.makeQuery()
//                .filter("year", .equals, year)
//                .filter("month", .equals, month)
//                .filter("day", .equals, day)
//                .all()
//            for session in sessions {
//                results += session.requests
//            }
//        } catch {
//            return "0"
//        }
//        return String(results)
//    }
    
//    static func statisticsForMonth() -> String {
//        var results = 0
//        guard let (_, month, year) = Date().calendarComponents else { return "0" }
//        do {
//            let sessions = try Session.makeQuery()
//                .filter("year", .equals, year)
//                .filter("month", .equals, month)
//                .all()
//            for session in sessions {
//                results += session.requests
//            }
//        } catch {
//            return "0"
//        }
//        return String(results)
//    }
}
