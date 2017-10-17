//
//  ImportError.swift
//  App
//
//  Created by Yura Voevodin on 16.10.17.
//

import Debugging
import Foundation

enum ImportError {
    case failedToImportRecord
}

extension ImportError: Debuggable {
    
    var reason: String {
        return "Value not found in JSON"
    }
    
    var identifier: String {
        return "failedToImportRecord"
    }
    
    var possibleCauses: [String] {
        return ["Failed to read JSON"]
    }
    
    var suggestedFixes: [String] {
        return [""]
    }
}
