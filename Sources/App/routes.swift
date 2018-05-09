import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let groups = try GroupController(drop: self)
    resource("groups", groups)
    
    // Telegram
    _ = try TelegramController(drop: self)
    
    // Facebook Messenger
    _ = try MessengerController(drop: self)
}
