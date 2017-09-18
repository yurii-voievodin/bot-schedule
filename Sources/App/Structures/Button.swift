//
//  Button.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 18.09.17.
//
//

import Foundation

/// Button of Facebook Messenger structured message element.
struct Button: NodeRepresentable {
    /// Button type of Facebook Messenger structured message element.
    ///
    /// - webURL: Web URL type.
    /// - postback: Postback type.
    enum `Type`: String {
        case webURL = "web_url"
        case postback = "postback"
    }
    
    /// Set all its property to get only.
    /// https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/AccessControl.html#//apple_ref/doc/uid/TP40014097-CH41-ID18
    /// Button type.
    private(set) var type: Type
    /// Button title.
    private(set) var title: String
    /// Button payload, postback type only.
    private(set) var payload: String?
    /// Button URL, webURL type only.
    private(set) var url: String?
    
    /// Creates a Button for Facebook Messenger structured message element.
    ///
    /// - Parameters:
    ///   - type: Button type.
    ///   - title: Button title.
    ///   - payload: Button payload.
    ///   - url: Button URL.
    /// - Throws: Throws NodeError errors.
    init(type: Type, title: String, payload: String? = nil, url: String? = nil) throws {
        /// Set Button type.
        self.type = type
        /// Set Button title.
        self.title = title
        
        /// Check what Button type is.
        switch type {
        /// Is a webURL type, so se its url.
        case .webURL:
            /// Check if url is nil.
            guard let url = url else {
                throw MessengerBotError.missingURL
            }
            self.url = url
        /// Is a postback type, so se its payload.
        case .postback:
            /// Check if payload is nil.
            guard let payload = payload else {
                throw MessengerBotError.missingPayload
            }
            self.payload = payload
        }
    }
    
    /// Button conforms to NodeRepresentable, turn the convertible into a node.
    ///
    /// - Parameter context: Context beyond Node.
    /// - Returns: Returns the Button Node representation.
    /// - Throws: Throws NodeError errors.
    public func makeNode(in context: Context?) throws -> Node {
        /// Create the Node with type and title.
        var node: Node = [
            "type": type.rawValue.makeNode(in: nil),
            "title": title.makeNode(in: nil)
        ]
        
        /// Extends the Node with url or payload, depends on Button type.
        switch type {
        /// Extends with url property.
        case .webURL:
            node["url"] = url?.makeNode(in: nil) ?? ""
        /// Extends with payload property.
        case .postback:
            node["payload"] = payload?.makeNode(in: nil) ?? ""
        }
        
        /// Create the Node.
        return Node(node: node)
    }
}
