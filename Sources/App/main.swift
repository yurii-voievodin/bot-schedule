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

// Setting up the POST request with the secret key.
// With a secret path to be sure that nobody else knows that URL.
// https://core.telegram.org/bots/api#setwebhook
drop.post(secret) { request in
    /// Let's prepare the response message text.
    var response = ""

    /// Chat ID from request JSON.
    let chatID = request.data["message", "chat", "id"]?.int ?? 0
    /// Message text from request JSON.
    let message = request.data["message", "text"]?.string ?? ""
    /// User first name from request JSON.
    var userFirstName = request.data["message", "from", "first_name"]?.string ?? ""

    // Check if the message is empty
    guard !message.characters.isEmpty else {
        return try JSON(node: [])
    }

    // Check if the message is a Telegram command.
    if message.hasPrefix("/") {
        let newLine = "\n\n"

        // Check what type of command is.
        switch message {
        // Start command "/start".
        case "/start", "/start start":
            // Set the response message text.
            response = "Вас вітає бот розкладу СумДУ! 😜" + newLine +
                "Увага, бот знаходиться на стадії розробки, тому деякі команди можуть бути недоступні!" + newLine +
                "Для зв'язку з розробником пишіть сюди - @voevodin_yura" + newLine +
                "Ви можете здійснювати пошук за назвою групи, аудиторією або фамілією викладача." + newLine +
            "Для перегляду доступних команд використовуйте /help"

        // Help command "/help".
        case "/help":
            // Set the response message text.
            response = "Увага, бот знаходиться на стадії розробки, тому деякі команди можуть бути недоступні!" + newLine +
                "/start - Початок роботи" + "\n" +
                "/help - Допомога" + newLine +
            "Для зв'язку з розробником пишіть сюди - @voevodin_yura"
        // Command not valid.
        default:
            return try JSON(node: [])
        }
        // It isn't a Telegram command.
    } else {
        // Set the response message text.
        response = "Вибачте, пошук поки що не працює" + "\n" +
        "Для зв'язку з розробником пишіть сюди - @voevodin_yura"
    }

    // Create the JSON response.
    // https://core.telegram.org/bots/api#sendmessage
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
