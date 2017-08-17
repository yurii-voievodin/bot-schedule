import Vapor

final class Routes: RouteCollection {
    
    // MARK: - Properties
    
    let drop: Droplet
    let client: ClientFactoryProtocol
    let view: ViewRenderer
    
    // MARK: - Initialization
    
    init(_ client: ClientFactoryProtocol, drop: Droplet, view: ViewRenderer) {
        self.client = client
        self.drop = drop
        self.view = view
    }
    
    // MARK: - Setup
    
    func build(_ builder: RouteBuilder) throws {
        
        /// Read the secret key from Config/secrets/app.json.
        guard let secret = drop.config["app", "secret"]?.string else {
            throw BotError.missingSecretKey
        }
        
        // Setting up the POST request with the secret key.
        // With a secret path to be sure that nobody else knows that URL.
        // https://core.telegram.org/bots/api#setwebhook
        let commandsController = CommandsController(client: client, secret: secret)
        builder.post(secret, handler: commandsController.index)
    }
    
    /// Bot errors
    enum BotError: Swift.Error {
        /// Missing secret key in Config/secrets/app.json.
        case missingSecretKey
    }
}
