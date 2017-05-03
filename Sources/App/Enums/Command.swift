//
//  Command.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 03.05.17.
//
//

import Foundation

extension CommandsController {
    
    enum Command: String {
        case start = "/start"
        case firstStart = "/start start"
        case help = "/help"
        case search = "/search"
        case statistics = "/statistics"
        
        var response: String {
            switch self {
            case .start, .firstStart:
                return "Вас вітає бот розкладу СумДУ! 🙋‍♂️" + twoLines
                    + "🔍 Шукайте за назвою групи, аудиторією або прізвищем викладача." + twoLines
                    + "/help - Допомога"
            case .help:
                return "/start - Початок роботи ⭐️" + newLine
                    + "/help - Допомога ⁉️" + newLine
                    + "/search - Пошук 🔍" + newLine
                    + "/statistics - Статистика використання бота 📊" + twoLines
                    + "🛠 Зв'язатися з розробником - @voevodin_yura"
            case .search:
                return "🔍 Введіть назву аудиторії, групи або ініціали викладача"
            case .statistics:
                return "Кількість запитів:" + newLine
                    + " - за сьогодні: " + Session.statisticsForToday() + newLine
                    + " - у цьому місяці: " + Session.statisticsForMonth()
            }
        }
    }
}
