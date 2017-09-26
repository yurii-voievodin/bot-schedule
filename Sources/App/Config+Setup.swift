import FluentProvider
import LeafProvider
import PostgreSQLProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        
        try setupProviders()
        try setupPreparations()
        try setupMiddlewares()
        try setupCommands()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)
        try addProvider(PostgreSQLProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations += [
            Auditorium.self,
            Group.self,
            Teacher.self,
            BotUser.self,
            HistoryRecord.self,
            Record.self,
            Session.self
            ] as [Preparation.Type]
    }
    
    private func setupMiddlewares() throws {
        
    }
    
    private func setupCommands() throws {
        addConfigurable(command: ImportCommand.init, name: "import")
        addConfigurable(command: TestCommand.init, name: "test")
        addConfigurable(command: MessengerComand.init, name: "messenger")
    }
}
