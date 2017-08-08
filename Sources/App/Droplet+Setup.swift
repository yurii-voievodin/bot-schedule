@_exported import Vapor

extension Droplet {
    public func setup() throws {
        let client = try config.resolveClient()
        
        let routes = Routes(view, client: client)
        try collection(routes)
    }
}
