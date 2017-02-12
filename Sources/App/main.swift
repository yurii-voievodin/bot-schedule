import Vapor
import VaporPostgreSQL

// Preparations
let preparations = [Object.self]

// Providers
let providers = [VaporPostgreSQL.Provider.self]

// Droplet
let drop = Droplet(
    preparations: preparations,
    providers: providers
)
Object.database = drop.database

// Commands
drop.commands.append(FetchDataCommand(console: drop.console, droplet: drop))

// Check database connection
drop.get("version") { request in
    if let db = drop.database?.driver as? PostgreSQLDriver {
        let version = try db.raw("SELECT version()")
        return JSON(version)
    } else {
        return "No db connection"
    }
}

drop.run()
