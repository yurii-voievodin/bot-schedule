//
//  AuthController.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 17.04.17.
//
//

import Vapor
import HTTP
import Turnstile

final class AuthController {

    // MARK: - Routes

    func addRoutes(drop: Droplet) {
        let auth = drop.grouped("auth")
        auth.get("register", handler: registerView)
        auth.post("register", handler: register)
        auth.get("login", handler: loginView)
        auth.post("login", handler: login)
        auth.get("logout", handler: logout)
    }

    // MARK: - Register

    func registerView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("register")
    }

    func register(request: Request) throws -> ResponseRepresentable {
        guard let email = request.formURLEncoded?["email"]?.string,
            let password = request.formURLEncoded?["password"]?.string else {
                return "Missing email or password"
        }
        try Admin.register(email: email, rawPassword: password)

        // Login registered user
        let credentials = UsernamePassword(username: email, password: password)
        try request.auth.login(credentials)

        return Response(redirect: "/messages")
    }

    // MARK: - Login

    func loginView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("login")
    }

    func login(request: Request) throws -> ResponseRepresentable {
        guard let email = request.formURLEncoded?["email"]?.string,
            let password = request.formURLEncoded?["password"]?.string else {
                return "Missing email or password"
        }
        let credentials = UsernamePassword(username: email, password: password)
        do {
            try request.auth.login(credentials)
            return Response(redirect: "/messages")
        } catch let e as TurnstileError {
            return e.description
        }
    }

    func logout(request: Request) throws -> ResponseRepresentable {
        try request.auth.logout()
        return Response(redirect: "/auth/login")
    }
}
