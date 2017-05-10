//
//  RequestsManager.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 10.05.17.
//
//

import Foundation

class RequestsManager {
    
    static let shared = RequestsManager()
    
    func addRequest() {
        guard let (day, month, year) = Date().calendarComponents else { return }
        
        do {
            if var session = try Session.query()
                .filter("year", .equals, year)
                .filter("month", .equals, month)
                .filter("day", .equals, day)
                .first() {
                session.requests += 1
                try session.save()
            } else {
                var newSession = Session(day: day, month: month, year: year, requests: 1)
                try newSession.save()
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
}
