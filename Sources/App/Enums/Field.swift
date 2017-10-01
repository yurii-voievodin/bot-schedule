//
//  Field.swift
//  App
//
//  Created by Yura Voevodin on 01.10.17.
//

import Foundation

enum Field {
    
    case serverID
    case name
    case updatedAt
    case lowercaseName
    
    var name: String {
        switch self {
        case .lowercaseName:
            return "lowercase_name"
        case .name:
            return "name"
        case .serverID:
            return "server_id"
        case .updatedAt:
            return "updated_at"
        }
    }
}
