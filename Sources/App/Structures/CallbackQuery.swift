//
//  CallbackQuery.swift
//  App
//
//  Created by Yura Voevodin on 08.10.17.
//

import Foundation

struct CallbackQuery: JSONInitializable {
    
    let id: String
    let data: String
    
    init(id: String, data: String) {
        self.id = id
        self.data = data
    }
    
    init(json: JSON) throws {
        try self.init(
            id: json.get("id"),
            data: json.get("data")
        )
    }
}
