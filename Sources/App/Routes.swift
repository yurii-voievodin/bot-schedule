import Vapor

extension Droplet {
    
    func setupRoutes() throws {
        
        try resource("groups", GroupController.self)
        
        // Telegram
        _ = try CommandsController(drop: self)
        
        // Facebook Messenger
        _ = try MessengerController(drop: self)
    }
}
