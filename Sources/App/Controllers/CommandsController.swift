//
//  CommandsController.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 04.03.17.
//
//

import Vapor
import HTTP

final class CommandsController {

    enum Command: String {
        case start = "/start"
        case firstStart = "/start start"
        case help = "/help"

        var response: String {
            let newLine = "\n\n"

            switch self {
            case .start, .firstStart:
                return "Вас вітає бот розкладу СумДУ! 😜" + newLine +
                    "Увага, бот знаходиться на стадії розробки, тому деякі команди можуть бути недоступні!" + newLine +
                    "Для зв'язку з розробником пишіть сюди - @voevodin_yura" + newLine +
                    "Ви можете здійснювати пошук за назвою групи, аудиторією або фамілією викладача." + newLine +
                "Для перегляду доступних команд використовуйте /help"
            case .help:
                return "Увага, бот знаходиться на стадії розробки, тому деякі команди можуть бути недоступні!" + newLine +
                    "/start - Початок роботи" + "\n" +
                    "/help - Допомога" + newLine +
                "Для зв'язку з розробником пишіть сюди - @voevodin_yura"
            }
        }
    }

    // MARK: - Actions

    func index(request: Request) throws -> ResponseRepresentable {
        /// Let's prepare the response message text
        var response = ""
        /// Chat ID from request JSON
        let chatID = request.data["message", "chat", "id"]?.int ?? 0
        /// Message text from request JSON
        let message = request.data["message", "text"]?.string ?? ""

        // Check if the message is empty
        guard !message.characters.isEmpty else {
            return try JSON(node: [])
        }

        // Check if the message is a Telegram command
        if let command = Command(rawValue: message.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)) {
            response = command.response
        } else {
            // It isn't a Telegram command
            response = "Вибачте, пошук поки що не працює не повністю" + "\n" +
            "Для зв'язку з розробником пишіть сюди - @voevodin_yura"

            let objects = try Object.findObjects(with: message)
            if objects.characters.count > 0 {
                response = "\n\n" + objects
            } else {
                response = "За вашим запитом нічого не знайдено, спробуйте інший"
            }
        }

        // Create the JSON response
        // https://core.telegram.org/bots/api#sendmessage
        return try JSON(node:
            [
                "method": "sendMessage",
                "chat_id": chatID,
                "text": response
            ]
        )
    }
}
