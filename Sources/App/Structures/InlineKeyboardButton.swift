//
//  InlineKeyboardButton.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 03.10.17.
//
//

import Foundation

struct InlineKeyboardButton: NodeRepresentable {
    
    let text: String
    let callbackData: String
    
    func makeNode(in context: Context?) throws -> Node {
        let node: Node = [
            "text": text.makeNode(in: nil),
            "callback_data": callbackData.makeNode(in: nil)
        ]
        return Node(node: node)
    }
}
