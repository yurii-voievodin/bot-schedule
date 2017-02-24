//
//  Date.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 24.02.17.
//
//

import Foundation

extension Date {

    /// String representation of the date in server format
    public var serverDateFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: self)
    }
}
