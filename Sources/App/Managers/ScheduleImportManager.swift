//
//  ScheduleImportManager.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 11.03.17.
//
//

import Vapor
import HTTP
import Foundation
import FluentPostgreSQL

struct ScheduleImportManager {
    
    // MARK: - Types
    
    /// Import errors
    enum ImportError: Swift.Error {
        case failedGetArray
        case missingObjectID
        case missingObject
    }
    
    // MARK: - Methods
    
    /// Make request of schedule for object
    static func makeRequestOfSchedule(for type: ObjectType, id: Int, client: ClientFactoryProtocol) throws -> Response {
        var groupId = "0"
        var teacherId = "0"
        var auditoriumId = "0"
        switch type {
        case .auditorium:
            auditoriumId = String(id)
        case .group:
            groupId = String(id)
        case .teacher:
            teacherId = String(id)
        }
        
        // Time interval for request
        let startDate = Date()
        let oneDay: TimeInterval = 60*60*24*8
        let endDate = startDate.addingTimeInterval(oneDay)
        
        let baseURL = "http://schedule.sumdu.edu.ua/index/json?method=getSchedules"
        let query = "&id_grp=\(groupId)&id_fio=\(teacherId)&id_aud=\(auditoriumId)&date_beg=\(startDate.serverDate)&date_end=\(endDate.serverDate)"
        
        return try client.get(baseURL + query)
    }
    
    static func importSchedule(for type: ObjectType, id: Int, client: ClientFactoryProtocol) throws {
        // Make request and node from JSON response
        let scheduleResponse = try makeRequestOfSchedule(for: type, id: id, client: client)
        guard let responseArray = scheduleResponse.json?.array else { throw ImportError.failedGetArray }
        for item in responseArray {
            let record = try Record.row(from: item)
            try record.save()
        }
    }
}
