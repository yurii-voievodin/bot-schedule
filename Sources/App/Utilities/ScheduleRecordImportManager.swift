//
//  ScheduleRecordImportManager.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 25.02.17.
//
//

import Vapor
import Fluent

final class ScheduleRecordImportManager {

    func importFrom(node nodeForImport: Node, for objectID: Node) throws {
        guard let nodeArray = nodeForImport.nodeArray else { return }

        for node in nodeArray {
            var nodeRecord = node

            nodeRecord["object_id"] = objectID
            var record = try ScheduleRecord(node: nodeRecord)
            try record.save()
        }
    }
}
