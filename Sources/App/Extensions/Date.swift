//
//  Date.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 24.02.17.
//
//

import Foundation

extension Date {

    // MARK: Properties

    static var serverFormat: String {
        return "dd.MM.yyyy"
    }

    /// String representation of the date in server format
    var serverDateFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = Date.serverFormat
        return formatter.string(from: self)
    }

    /// Generate string representation of date with format "dd MMMM yyyy"
    var humanReadable: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: self)
    }

    // MARK: Helpers

    static func serverDate(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = Date.serverFormat
        return formatter.date(from: dateString)
    }
}
