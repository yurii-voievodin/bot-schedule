//
//  MessengerBotError.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 18.09.17.
//
//

import Foundation

/// Bot errors enum.
enum MessengerBotError: Swift.Error {
    /// Missing Facebook Messenger secret key in Config/secrets/app.json.
    case missingAppSecrets
    /// Missing URL in Facebook Messenger structured message button.
    case missingURL
    /// Missing payload in Facebook Messenger structured message button.
    case missingPayload
}
