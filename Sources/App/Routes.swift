import Vapor

extension Droplet {
    
    func setupRoutes() throws {
        
        let groups = try GroupController(drop: self)
        resource("groups", groups)
        
        // Telegram
        _ = try TelegramController(drop: self)
        
        // Facebook Messenger
        _ = try MessengerController(drop: self)
    }
}
