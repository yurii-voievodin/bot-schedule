//
//  ScheduleImportManager.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 11.03.17.
//
//

import Vapor
import Foundation
import HTTP

struct ScheduleImportManager {

    /// Import errors
    enum ImportError: Swift.Error {
        case failedGetArray
        case missingObjectID
        case missingObject
    }

    /// Import records from array
    ///
    /// - Parameters:
    ///   - array: [Polymorphic] array of records from Response
    ///   - objectID: Id of Object in database
    static func importFrom(_ array: [Polymorphic], for objectID: Node) throws {
        for item in array {
            if let object = item.object, var record = ScheduleRecord(object) {
                record.objectID = objectID
                try record.save()
            }
        }
    }

    /// Make request of schedule for object
    ///
    /// - Parameter object: for which get schedule
    /// - Returns: schedule as json
    static func makeRequestOfSchedule(_ object: Object) throws -> Response {
        // Detect type of object
        guard let type = ObjectType(rawValue: object.type) else {
            print("❌ Failed to detect type of object")
            return Response()
        }
        var groupId = "0"
        var teacherId = "0"
        var auditoriumId = "0"
        switch type {
        case .auditorium:
            auditoriumId = String(object.serverID)
        case .group:
            groupId = String(object.serverID)
        case .teacher:
            teacherId = String(object.serverID)
        }

        // Time interval for request
        let startDate = Date()
        let oneDay: TimeInterval = 60*60*24*14
        let endDate = startDate.addingTimeInterval(oneDay)

        // Query parameters
        let query: [String: CustomStringConvertible] = [
            "data[DATE_BEG]": startDate.serverDateFormat,
            "data[DATE_END]": endDate.serverDateFormat,
            "data[KOD_GROUP]": groupId,
            "data[ID_FIO]": teacherId,
            "data[ID_AUD]": auditoriumId
        ]
        return try drop.client.post("http://schedule.sumdu.edu.ua/index/json", query: query)
    }

    static func importSchedule(for object: Object) throws {
        // Make request and node from JSON response
        let scheduleResponse = try makeRequestOfSchedule(object)
        guard let responseArray = scheduleResponse.json?.array else { throw ImportError.failedGetArray }

        // Id of related object
        guard let objectID = object.id else { throw ImportError.missingObjectID }

        // Try to delete old records
        try object.records().delete()

        // Try to import new records
        try ScheduleImportManager.importFrom(responseArray, for: objectID)
    }
}
