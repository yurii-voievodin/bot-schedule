//
//  configure.swift
//  App
//
//  Created by Yura Voevodin on 09.05.18.
//

import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Auditorium.self, database: .psql)
    services.register(migrations)
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    /// Register custom PostgreSQL Config
    let psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "voevodin")
    services.register(psqlConfig)
    
    // MARK: Commands
    
    /// Create a `CommandConfig` with default commands.
    var commandConfig = CommandConfig.default()
    /// Add the `CowsayCommand`.
    commandConfig.use(ImportCommand(), as: "import")
    /// Register this `CommandConfig` to services.
    services.register(commandConfig)
    
    // Configure a PostgreSQL database
//    let postgreSQL = try PostgreSQLDatabase(storage: .memory)
//    
//    /// Register the configured SQLite database to the database config.
//    var databases = DatabasesConfig()
//    databases.add(database: postgreSQL, as: .sqlite)
//    services.register(databases)
}
