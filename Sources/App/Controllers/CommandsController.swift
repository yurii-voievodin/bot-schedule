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
        case info = "/info"
        case search = "/search"
        case statistics = "/statistics"

        var response: String {
            switch self {
            case .start, .firstStart:
                return "Вас вітає бот розкладу СумДУ! 😜" + twoLines
                    + "⚠️ Увага, бот знаходиться на стадії розробки, тому деякі команди можуть бути недоступні!" + twoLines
                    + "🛠 Для зв'язку з розробником пишіть сюди - @voevodin_yura" + twoLines
                    + "🔍 Ви можете здійснювати пошук за назвою групи, аудиторією або прізвищем викладача." + twoLines
                    + "Для перегляду доступних команд використовуйте /help"

            case .help:
                return "⚠️ Увага, бот знаходиться на стадії розробки, тому деякі команди можуть бути недоступні!" + twoLines
                    + "/start - Початок роботи ⭐️" + newLine
                    + "/help - Допомога" + newLine
                    + "/info - Інформація ℹ️" + newLine
                    + "/search - Пошук 🔍" + newLine
                    + "/statistics - Статистика використання бота" + twoLines
                    + "🛠 Для зв'язку з розробником пишіть сюди - @voevodin_yura"

            case .info:
                return "📚 Бібліотеки: " + twoLines
                    + "Vapor - A web framework and server for Swift that works on macOS and Ubuntu. (https://vapor.codes)" + twoLines
                    + "Kanna - XML/HTML parser for Swift. (https://github.com/tid-kijyun/Kanna.git)" + twoLines
                    + "PostgreSQL Provider for the Vapor web framework. (https://github.com/vapor/postgresql-provider)" + twoLines
                    + "Delightful console output for Swift developers. (https://github.com/onevcat/Rainbow)" + twoLines
                    + "💡 Ідея розробки - https://github.com/appdev-academy/sumdu-ios"

            case .search:
                return "🔍 Введіть назву аудиторії, групи або ініціали викладача"
            case .statistics:
                return "Кількість запитів за сьогодні: " + Session.statisticsForToday() + newLine
                    + "Кількість запитів у цьому місяці: " + Session.statisticsForMonth()
            }
        }
    }

    // MARK: - Initialization

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

            if command == .statistics {

                // Run async job with response
                Jobs.oneoff {
                    try self.sendResponse(chatID: chatID, text: responseText)
                }

                // Response with "typing"
                return try JSON(node: [
                    "method": "sendChatAction",
                    "chat_id": request.data["message", "chat", "id"]?.int ?? 0,
                    "action": "typing"
                    ])
            }

        } else if message.hasPrefix("/info_") {
            // It isn't a command

            responseText = "🤷‍♂️ Вибачте, але пошук тимчасово не працює в зв'язку з проблемами на сайті СумДУ"

            // TODO: Enable search later
//            responseText = try findSchedule(for: message)

        } else {
            // Search objects
            let objects = try Object.find(with: message)
            if objects.characters.count > 0 {
                responseText = objects
            }
        }
        // Generate response node
        // https://core.telegram.org/bots/api#sendmessage
        return try JSON(node: [
            "method": "sendMessage",
            "chat_id": request.data["message", "chat", "id"]?.int ?? 0,
            "text": responseText
            ])
    }
}

// MARK: - Helpers

extension CommandsController {

    fileprivate func findSchedule(for message: String) throws -> String {
        var response = emptyResponseText

        // Get ID of Object from message (/info_{id})
        let idString = message.substring(from: message.index(message.startIndex, offsetBy: 6))
        guard let id = Int(idString) else { return response }

        // Try to find records
        let records = try ScheduleRecord.findSchedule(by: id)
        if records.characters.count > 0 {
            response = records
        }
        return response
    }

    fileprivate func sendResponse(chatID: Int, text: String) throws {
        let json = try JSON(node: [
            "method": "sendMessage",
            "chat_id": chatID,
            "text": text
            ])
        let jsonBytes = try json.makeBytes()
        let response = try drop.client.post("https://api.telegram.org/bot\(secret)/sendMessage", headers: [:], body: Body.data(jsonBytes))

        print(response.json ?? "Response JSON not found")
    }
}
