import Vapor

extension Droplet {
    
    func setupRoutes() throws {
        
        // Telegram
        _ = try CommandsController(drop: self)
    }
}
