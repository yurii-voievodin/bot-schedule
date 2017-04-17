//
//  EmailValidator.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 17.04.17.
//
//

import Vapor

class EmailValidator: ValidationSuite {

    static func validate(input value: String) throws {
        let evaluation = Email.self && Count.containedIn(low: 6, high: 64)
        try evaluation.validate(input: value)
    }
}
