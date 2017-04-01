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
    var serverDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = Date.serverFormat
        return formatter.string(from: self)
    }

    /// String representation of the date for statistics, format "dd MMMM yyyy HH"
    var dateWithHour: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy HH"
        return formatter.string(from: self)
    }

    /// "dd MMMM yyyy"
    var dayMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: self)
    }

    /// "MMMM yyyy"
    var monthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }

    /// Generate string representation of date with format "dd MMMM yyyy"
    var humanReadable: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMMM yyyy"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: self)
    }

    var intDate: (year: Int, month: Int, day: Int, hour: Int)? {
        let formatter = DateFormatter()

        // Year
        formatter.dateFormat = "yyyy"
        let yearString = formatter.string(from: self)
        let year = yearString.int

        // Month
        formatter.dateFormat = "M"
        let monthString = formatter.string(from: self)
        let month = monthString.int

        // Day
        formatter.dateFormat = "d"
        let dayString = formatter.string(from: self)
        let day = dayString.int

        // Hour
        formatter.dateFormat = "H"
        let hourString = formatter.string(from: self)
        let hour = hourString.int

        if let year = year, let month = month, let day = day, let hour = hour {
            return (year, month, day, hour)
        } else {
            return nil
        }
    }

    // MARK: Helpers

    static func serverDate(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = Date.serverFormat
        return formatter.date(from: dateString)
    }
}
