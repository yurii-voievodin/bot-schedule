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

        let currentTime = Date().dateWithHour

        if var session = try Session.query().filter("date", .equals, currentTime).first() {
            session.requests += 1
            try session.save()
        } else {
            var session = Session(date: currentTime, requests: 1)
            try session.save()
        }

        return response
    }
}
