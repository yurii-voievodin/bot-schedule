import Vapor
import VaporPostgreSQL
import Fluent

/// Bot errors
enum BotError: Swift.Error {
    /// Missing secret key in Config/secrets/app.json.
    case missingSecretKey
}

/// Droplet
let drop = Droplet()

/// Read the secret key from Config/secrets/app.json.
guard let secret = drop.config["app", "secret"]?.string else {
    // Show errors in console.
    drop.console.error("Missing secret key!")
    drop.console.warning("Add one in Config/secrets/app.json")

    // Throw missing secret key error.
    throw BotError.missingSecretKey
}

// Providers
try drop.addProvider(VaporPostgreSQL.Provider.self)

// Migrations before tables
drop.preparations += DeleteSession.self

// Preparations
let models = [
    Auditorium.self,
    Group.self,
    Teacher.self,
    Record.self,
    Session.self,
    User.self
    ] as [Preparation.Type]

for model in models {
    drop.preparations += model
}

// Database
Auditorium.database = drop.database
Group.database = drop.database
Teacher.database = drop.database
Record.database = drop.database
Session.database = drop.database

// Commands
drop.commands.append(ImportCommand(console: drop.console, droplet: drop))

// Middleware
drop.middleware.append(SessionMiddleware())
drop.middleware.append(UserMiddleware())

// Setting up the POST request with the secret key.
// With a secret path to be sure that nobody else knows that URL.
// https://core.telegram.org/bots/api#setwebhook
let commandsController = CommandsController(secret: secret)
drop.post(secret, handler: commandsController.index)

// Run droplet
drop.run()
