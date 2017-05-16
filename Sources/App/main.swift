import Vapor
import VaporPostgreSQL
import Fluent
import Auth

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

// Response manager
ResponseManager.shared.secret = secret

// Configurable
drop.addConfigurable(middleware: AuthMiddleware(user: Admin.self), name: "auth")

// Providers
try drop.addProvider(VaporPostgreSQL.Provider.self)

// Migrations before tables
drop.preparations += DeleteSession.self

// Preparations
drop.preparations += [
    Admin.self,
    Auditorium.self,
    Group.self,
    Teacher.self,
    Record.self,
    Session.self,
    BotUser.self,
    HistoryRecord.self
] as [Preparation.Type]

// Database
Auditorium.database = drop.database
Group.database = drop.database
Teacher.database = drop.database
Record.database = drop.database
Session.database = drop.database

// Commands
drop.commands.append(ImportCommand(console: drop.console, droplet: drop))

// Setting up the POST request with the secret key.
// With a secret path to be sure that nobody else knows that URL.
// https://core.telegram.org/bots/api#setwebhook
let commandsController = CommandsController(secret: secret)
drop.post(secret, handler: commandsController.index)

// Auth
let authController = AuthController()
authController.addRoutes(drop: drop)

// Messages
let messagesController = MessagesController()
messagesController.addRoutes(drop: drop)

// Run droplet
drop.run()
