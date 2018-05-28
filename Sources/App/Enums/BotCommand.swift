//
//  BotCommand.swift
//  SumDUBot
//
//  Created by Yura Voevodin on 03.05.17.
//
//

import Vapor

enum BotCommand: String {
    
    case help = "/help"
    case history = "/history"
    case search = "/search"
    case start = "/start"
    case statistics = "/statistics"
    case test = "/test"
    
    var response: String {
        switch self {
        case .help:
            return "/help - Допомога ⁉️" + newLine
                + "/history - Історія запитів" + newLine
                + "/search - Пошук 🔍" + newLine
                + "/start - Початок роботи ⭐️" + newLine
                + "/statistics - Статистика використання бота 📊" + twoLines
                + "🛠 Зв'язатися з розробником - @voevodin_yura"
        case .history:
            return ""
        case .search:
            return "🔍 Введіть назву аудиторії, групи або ініціали викладача"
        case .start:
            return "Вас вітає бот розкладу СумДУ! 🙋‍♂️" + twoLines
                + "🔍 Шукайте за назвою групи, аудиторією або прізвищем викладача." + twoLines
                + "/help - Допомога"
        case .statistics:
            return "Кількість запитів:" + newLine
//                + " - за сьогодні: " + Session.statisticsForToday() + newLine
//                + " - у цьому місяці: " + Session.statisticsForMonth() + newLine
                + "Кількість користувачів: " + BotUser.countOfUsers()
            
        case .test:
            return ""
        }
    }
}

