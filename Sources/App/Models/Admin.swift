//
//  Admin.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 17.04.17.
//
//

import Vapor
import FluentProvider
import Turnstile
import TurnstileCrypto
//import ValidationProvider
import AuthProvider

final class Admin: Model, User {
    let storage = Storage()
    
    // MARK: Properties
    
    var email: Valid<EmailValidator>
    var password: String
    
    // MARK: - Initialization
    
    init(email: String, rawPassword: String) throws {
        self.email = try email.validated()
        let validatedPassword: Valid<PasswordValidator> = try rawPassword.validated()
        self.password = BCrypt.hash(password: validatedPassword.value)
    }
    
    // MARK: - Node
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        let emailString = try node.extract("email") as String
        email = try emailString.validated()
        let passwordString = try node.extract("password") as String
        password = passwordString
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "email": email.value,
            "password": password,
            ]
        )
    }
}

// MARK: - Preparation

extension Admin: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(entity) { admin in
            admin.id()
            admin.string("email")
            admin.string("password")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

// MARK: - Authenticator

extension Admin: Authenticator {
    
    static func authenticate(credentials: Credentials) throws -> User {
        var user: Admin?
        
        switch credentials {
        case let credentials as UsernamePassword:
            let fetchedUser = try Admin.query()
                .filter("email", credentials.username)
                .first()
            if let password = fetchedUser?.password,
                password != "",
                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetchedUser
            }
        case let credentials as Identifier:
            user = try Admin.find(credentials.id)
        default:
            throw UnsupportedCredentialsError()
        }
        
        if let user = user {
            return user
        } else {
            throw IncorrectCredentialsError()
        }
    }
    
    static func register(credentials: Credentials) throws -> User {
        throw Abort.badRequest
    }
}

// MARK: - Helpers

extension Admin {
    
    // TODO: Use register from Authenticator
    
    static func register(email: String, rawPassword: String) throws {
        let newAdmin = try Admin(email: email, rawPassword: rawPassword)
        guard var admin = try Admin.query().filter("email", newAdmin.email.value).first() else { throw Abort.badRequest }
        guard admin.password.characters.count == 0 else { throw Abort.badRequest }
        admin.password = newAdmin.password
        try admin.save()
    }
}
