@_exported import Vapor

extension Droplet {
    public func setup() throws {
        let client = try config.resolveClient()
        
        let routes = Routes(client, drop: self, view: view)
        try collection(routes)
    }
}
