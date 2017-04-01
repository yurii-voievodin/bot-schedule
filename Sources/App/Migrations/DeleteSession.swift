//
//  DeleteSession.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 01.04.17.
//
//

import Fluent

struct DeleteSession: Preparation {
    static func prepare(_ database: Database) throws {

        // Delete sessions
        try database.delete("sessions")
    }

    static func revert(_ database: Database) throws {
    }
}
