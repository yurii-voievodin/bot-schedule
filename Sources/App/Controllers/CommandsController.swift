//
//  CommandsController.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 04.03.17.
//
//

import Jobs
import HTTP
import Vapor

final class CommandsController {

    // MARK: - Constants

    fileprivate let emptyResponseText = "🙁 За вашим запитом нічого не знайдено, спробуйте інший"

    enum Command: String {
        case start = "/start"
        case firstStart = "/start start"
        case help = "/help"
        case search = "/search"
        case statistics = "/statistics"

        var response: String {
            switch self {
            case .start, .firstStart:
                return "Вас вітає бот розкладу СумДУ! 😜" + twoLines
                    + "🛠 Для зв'язку з розробником пишіть сюди - @voevodin_yura" + twoLines
                    + "🔍 Ви можете здійснювати пошук за назвою групи, аудиторією або прізвищем викладача." + twoLines
                    + "Для перегляду доступних команд використовуйте /help"

            case .help:
                return "⚠️ Увага, бот знаходиться на стадії розробки, тому деякі команди можуть бути недоступні!" + twoLines
                    + "/start - Початок роботи ⭐️" + newLine
                    + "/help - Допомога" + newLine
                    + "/search - Пошук 🔍" + newLine
                    + "/statistics - Статистика використання бота" + twoLines
                    + "🛠 Для зв'язку з розробником пишіть сюди - @voevodin_yura"

            case .search:
                return "🔍 Введіть назву аудиторії, групи або ініціали викладача"
            case .statistics:
                return "Кількість запитів за сьогодні: " + Session.statisticsForToday() + newLine
                    + "Кількість запитів у цьому місяці: " + Session.statisticsForMonth()
            }
        }
    }

    // MARK: - Initialization

    let secret: String
    init(secret: String) {
        self.secret = secret
    }

    // MARK: - Actions

    func index(request: Request) throws -> ResponseRepresentable {
        let chatID = request.data["message", "chat", "id"]?.int ?? 0

        // Message text from request JSON
        let message = (request.data["message", "text"]?.string ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        var responseText = emptyResponseText

        if let command = Command(rawValue: message) {
            // If it is a command
            responseText = command.response

            // Run async job with response
            Jobs.oneoff {
                try self.sendResponse(chatID, text: responseText)
            }
        } else if message.hasPrefix("/auditorium_") {
            // Show records for auditorium
            Jobs.oneoff {
                let result = try Auditorium.show(for: message)
                if result.characters.count > 0 {
                    responseText = result
                }
                try self.sendResponse(chatID, text: responseText)
            }
        } else if message.hasPrefix("/group_") {
            // Show records for group
            Jobs.oneoff {
                let result = try Group.show(for: message)
                if result.characters.count > 0 {
                    responseText = result
                }
                try self.sendResponse(chatID, text: responseText)
            }
        } else if message.hasPrefix("/teacher_") {
            // Show records for teacher
            Jobs.oneoff {
                let result = try Teacher.show(for: message)
                if result.characters.count > 0 {
                    responseText = result
                }
                try self.sendResponse(chatID, text: responseText)
            }
        } else {
            // Search
            Jobs.oneoff {
                var searchResults = ""
                searchResults += try Auditorium.find(by: message) + newLine
                searchResults += try Group.find(by: message) + newLine
                searchResults += try Teacher.find(by: message) + newLine
                if searchResults.characters.count > 0 {
                    responseText = searchResults
                }
                try self.sendResponse(chatID, text: responseText)
            }
        }
        // Response with "typing"
        return try JSON(node: [
            "method": "sendChatAction",
            "chat_id": chatID,
            "action": "typing"
            ]
        )
    }
}

// MARK: - Helpers

extension CommandsController {

    fileprivate func sendResponse(_ chatID: Int, text: String) throws {
        let node = try Node(node: [
            "method": "sendMessage",
            "chat_id": chatID,
            "text": text
            ])

        _ = try drop.client.post("https://api.telegram.org/bot\(secret)/sendMessage", headers: [
            "Content-Type": "application/x-www-form-urlencoded"
            ], body: Body.data(node.formURLEncoded()))
    }
}
