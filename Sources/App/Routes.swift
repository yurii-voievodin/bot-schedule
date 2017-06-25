import Vapor

final class Routes: RouteCollection {
    let view: ViewRenderer
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        
        // Setting up the POST request with the secret key.
        // With a secret path to be sure that nobody else knows that URL.
        // https://core.telegram.org/bots/api#setwebhook
//        let commandsController = CommandsController(secret: secret)
//        builder.post(secret, handler: commandsController.index)
        
//        // Auth
//        let authController = AuthController()
//        authController.addRoutes(drop: drop)
//        
//        // Messages
//        let messagesController = MessagesController()
//        messagesController.addRoutes(drop: drop)
    }
}
