//
//  Element.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 18.09.17.
//
//

import Foundation

/// Facebook Messenger structured message element.
//struct Element: NodeRepresentable {
//    /// Element title.
//    var title: String
//    /// Element subtitle.
//    var subtitle: String
//    /// Element item URL.
//    var itemURL: String
//    /// Element image URL.
//    var imageURL: String
//    /// Element Button array.
//    var buttons: [Button]
//    
//    /// Element conforms to NodeRepresentable, turn the convertible into a node.
//    ///
//    /// - Parameter context: Context beyond Node.
//    /// - Returns: Returns the Element Node representation.
//    /// - Throws: Throws NodeError errors.
//    public func makeNode(in context: Context?) throws -> Node {
//        /// Create the Node.
//        return try Node(node: [
//            "title": title.makeNode(in: nil),
//            "subtitle": subtitle.makeNode(in: nil),
//            "item_url": itemURL.makeNode(in: nil),
//            "image_url": imageURL.makeNode(in: nil),
//            "buttons": buttons.makeNode(in: nil)
//            ]
//        )
//    }
//}
