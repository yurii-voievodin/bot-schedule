//
//  ListObject.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 25.06.17.
//
//

import Vapor
import FluentProvider

protocol ListObject: Entity {
    
    // MARK: Properties
    
    var serverID: Int { get set }
    var name: String { get set }
    var updatedAt: String { get set }
    var lowercaseName: String { get set }
}
