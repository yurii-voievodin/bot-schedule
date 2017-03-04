import Vapor
import VaporPostgreSQL

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

// Preparations
drop.preparations += Object.self
drop.preparations += ScheduleRecord.self

// Database
Object.database = drop.database
ScheduleRecord.database = drop.database

// Commands
drop.commands.append(ImportCommand(console: drop.console, droplet: drop))

drop.get("") { request in
    return "SumDUBot"
}

let commandsController = CommandsController()

// Setting up the POST request with the secret key.
// With a secret path to be sure that nobody else knows that URL.
// https://core.telegram.org/bots/api#setwebhook
drop.post(secret, handler: commandsController.index)

// Run droplet
drop.run()
