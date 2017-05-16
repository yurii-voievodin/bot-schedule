//
//  ObjectType.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 03.05.17.
//
//

import Foundation

/// Type of object
enum ObjectType: Int {
    
    case auditorium = 0
    case group = 1
    case teacher = 2
    
    var prefix: String {
        switch self {
        case .auditorium:
            return "/auditorium_"
        case .group:
            return "/group_"
        case .teacher:
            return "/teacher_"
        }
    }
}
