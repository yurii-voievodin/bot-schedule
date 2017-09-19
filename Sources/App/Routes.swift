import Vapor

extension Droplet {
    
    func setupRoutes() throws {
        
        // Telegram
        _ = try CommandsController(drop: self)
        
        // Facebook Messenger
        _ = try MessengerController(drop: self)
    }
}
