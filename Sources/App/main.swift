import Vapor
import VaporPostgreSQL

/// Bot errors
enum BotError: Swift.Error {
    /// Missing secret key in Config/secrets/app.json.
    case missingSecretKey
}

// Droplet
let drop = Droplet()

/// Read the secret key from Config/secrets/app.json.
guard let secret = drop.config["app", "secret"]?.string else {
    /// Show errors in console.
    drop.console.error("Missing secret key!")
    drop.console.warning("Add one in Config/secrets/app.json")

    /// Throw missing secret key error.
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

    return "Hello!"
}

/// Setting up the POST request with the secret key.
/// With a secret path to be sure that nobody else knows that URL.
/// https://core.telegram.org/bots/api#setwebhook
drop.post(secret) { request in
    /// Let's prepare the response message text.
    var response = ""

    /// Chat ID from request JSON.
    let chatID = request.data["message", "chat", "id"]?.int ?? 0
    /// Message text from request JSON.
    let message = request.data["message", "text"]?.string ?? ""
    /// User first name from request JSON.
    var userFirstName = request.data["message", "from", "first_name"]?.string ?? ""

    /// Check if the message is empty
    if message.characters.isEmpty {
        /// Set the response message text.
        response = "I'm sorry but your message is empty 😢"
        /// The message is not empty
    } else {
        /// Check if the message is a Telegram command.
        if message.hasPrefix("/") {
            /// Check what type of command is.
            switch message {
            /// Start command "/start".
            case "/start":
                /// Set the response message text.
                response = "Welcome to SwiftyBot " + userFirstName + "!\n" +
                "To list all available commands type /help"
            /// Help command "/help".
            case "/help":
                /// Set the response message text.
                response = "Welcome to SwiftyBot " +
                    "an example on how create a Telegram bot with Swift using Vapor.\n" +
                    "https://www.fabriziobrancati.com/posts/how-create-telegram-bot-swift-vapor-ubuntu-macos\n\n" +
                    "/start - Welcome message\n" +
                    "/help - Help message\n" +
                "Any text - Returns the reversed message"
            /// Command not valid.
            default:
                /// Set the response message text and suggest to type "/help".
                response = "Unrecognized command.\n" +
                "To list all available commands type /help"
            }
            /// It isn't a Telegram command, so creates a reversed message text.
        } else {
            /// Set the response message text.
            response = "🙀"
        }
    }

    /// Create the JSON response.
    /// https://core.telegram.org/bots/api#sendmessage
    return try JSON(node:
        [
            "method": "sendMessage",
            "chat_id": chatID,
            "text": response
        ]
    )
}

// Run droplet
drop.run()
