//
//  SessionMiddleware.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 12.03.17.
//
//

import HTTP
import Foundation

final class SessionMiddleware: Middleware {

    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)

        guard let (year, month, day, hour) = Date().intDate else {
            return response
        }

        if var session = try Session.query()
            .filter("year", .equals, year)
            .filter("month", .equals, month)
            .filter("day", .equals, day)
            .filter("hour", .equals, hour)
            .first() {
            session.requests += 1
            try session.save()
        } else {
            var session = Session(year: year, month: month, day: day, hour: hour, requests: 1)
            try session.save()
        }

        return response
    }
}
