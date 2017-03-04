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
        let message = (request.data["message", "text"]?.string ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        // Check if the message is a Telegram command
        if let command = Command(rawValue: message) {
            node["text"] = command.response
        } else {
            // It isn't a Telegram command
            var response = "Вибачте, пошук поки що працює не повністю" + "\n\n"

            if message.hasPrefix("/info_") {
                // Info
                let idString = message.substring(from: message.index(message.startIndex, offsetBy: 6))
                response = "За вашим запитом нічого не знайдено, спробуйте інший"

                if let id = Int(idString) {
                    let records = try ScheduleRecord.findSchedule(by: id)
                    if records.characters.count > 0 {
                        response = records
                    }
                }

            } else {
                // Search
                let objects = try Object.findObjects(with: message)
                if objects.characters.count > 0 {
                    response =  objects
                }
            }
            node["text"] = response
        }
        
        return try JSON(node: node)
    }
}
