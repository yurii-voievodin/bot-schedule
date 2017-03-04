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
        // Generate response node
        // https://core.telegram.org/bots/api#sendmessage
        var node: [String : NodeRepresentable] = [
            "method": "sendMessage",
            "chat_id": request.data["message", "chat", "id"]?.int ?? 0
        ]

        // Message text from request JSON
        let message = request.data["message", "text"]?.string ?? ""
        let requestString = message.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Check if the message is a Telegram command
        if let command = Command(rawValue: requestString) {
            node["text"] = command.response
        } else {
            // It isn't a Telegram command
            var response = "Вибачте, пошук поки що працює не повністю" + "`\n\n`"

            let objects = try Object.findObjects(with: requestString)
            if objects.characters.count > 0 {
                response =  objects
            } else {
                response = "За вашим запитом нічого не знайдено, спробуйте інший"
            }
            node["text"] = response
            node["parse_mode"] = "Markdown"
        }

        return try JSON(node: node)
    }
}
