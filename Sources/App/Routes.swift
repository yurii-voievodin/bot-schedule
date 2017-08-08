import Vapor

final class Routes: RouteCollection {
    
    // MARK: - Properties
    
    let client: ClientFactoryProtocol
    let view: ViewRenderer
    
    // MARK: - Initialization
    
    init(_ view: ViewRenderer, client: ClientFactoryProtocol) {
        self.view = view
        self.client = client
    }
    
    // MARK: - Setup
    
    func build(_ builder: RouteBuilder) throws {
        
        // Setting up the POST request with the secret key.
        // With a secret path to be sure that nobody else knows that URL.
        // https://core.telegram.org/bots/api#setwebhook
        let commandsController = CommandsController(client: client)
        builder.post(ResponseManager.shared.secret, handler: commandsController.index)
        
//        // Auth
//        let authController = AuthController()
//        authController.addRoutes(drop: drop)
//        
//        // Messages
//        let messagesController = MessagesController()
//        messagesController.addRoutes(drop: drop)
    }
}
