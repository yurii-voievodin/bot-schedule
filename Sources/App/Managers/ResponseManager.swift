//
//  ResponseManager.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 01.05.17.
//
//

import HTTP
import Vapor

class ResponseManager {
    
    // MARK: - Properties
    
    static let shared = ResponseManager()
    var secret = ""
}
