//
//  InlineKeyboardButton.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 03.10.17.
//
//

import Foundation

struct InlineKeyboardButton: Codable {
    
    let text: String
    let callbackData: String
    
    enum CodingKeys: String, CodingKey {
        case callbackData = "callback_data"
        case text
    }
}
