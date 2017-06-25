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
    
    // MARK: - Methods
    
    func sendResponse(_ chatID: Int, text: String) throws {
//        let node = try Node(node: ["method": "sendMessage", "chat_id": chatID, "text": text])
//        let url = "https://api.telegram.org/bot\(secret)/sendMessage"
//        _ = try drop.client.post(url, headers: ["Content-Type": "application/x-www-form-urlencoded"], body: Body.data(node.formURLEncoded()))
    }
}
