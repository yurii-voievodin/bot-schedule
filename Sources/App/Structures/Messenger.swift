//
//  Messenger.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 18.09.17.
//
//

import Foundation

/// Struct to help with Facebook Messenger messages.
struct Messenger {
    /// Creates a standard Facebook Messenger message.
    ///
    /// - Parameter message: Message text to be sent.
    /// - Returns: Returns the created Node ready to be sent.
    static func message(_ message: String) -> Node {
        let message: Node = ["text": message.makeNode(in: nil)]
        return message
    }
    
    /// Creates a structured Messenger message.
    ///
    /// - Parameter elements: Elements of the structured message.
    /// - Returns: Returns the representable Node.
    /// - Throws: Throws NodeError errors.
    static func structuredMessage(elements: [Element]) throws -> Node {
        /// Create the Node.
        return try ["attachment":
            ["type": "template",
             "payload":
                ["template_type": "generic",
                 "elements": elements.makeNode(in: nil)
                ]
            ]
        ]
    }
    
    static func buttons(_ buttons: [Button], title: String? = nil) throws -> Node {
        /// Create the Node.
        return try [
            "attachment": [
                "type": "template",
                "payload":
                    [
                        "template_type": "button",
                        "text": title.makeNode(in: nil),
                        "buttons": buttons.makeNode(in: nil)
                ]
            ]
        ]
    }
}
