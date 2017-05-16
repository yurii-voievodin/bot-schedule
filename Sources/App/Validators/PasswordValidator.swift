//
//  PasswordValidator.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 17.04.17.
//
//

import Vapor

class PasswordValidator: ValidationSuite {

    static func validate(input value: String) throws {
        let range = value.range(of: "^(?=.*[0-9])(?=.*[A-Z])", options: .regularExpression)
        guard let _ = range else {
            throw error(with: value)
        }
    }
}
