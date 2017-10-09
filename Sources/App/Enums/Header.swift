//
//  Header.swift
//  App
//
//  Created by Yura Voevodin on 09.10.17.
//

import HTTP

enum Header {
    case urlencoded
    case json
    
    var value: [HeaderKey: String] {
        switch self {
        case .urlencoded:
            return [HeaderKey.contentType: "application/x-www-form-urlencoded"]
        case .json:
            return [HeaderKey.contentType: "application/json"]
        }
    }
}
