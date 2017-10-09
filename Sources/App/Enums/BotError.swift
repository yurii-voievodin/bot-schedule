//
//  BotError.swift
//  App
//
//  Created by Yura Voevodin on 09.10.17.
//

import Foundation

extension ResponseManager {
    
    /// Bot errors
    enum BotError: Swift.Error {
        /// Missing secret key in Config/secrets/app.json.
        case missingSecretKey
    }
}
