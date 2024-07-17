import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    // register routes
    let configuration = SQLPostgresConfiguration(hostname: "localhost",
                                                 port: 5432,
                                                 username: "shibotong",
                                                 password: nil,
                                                 database: "shibotong",
                                                 tls: .disable)
    
    app.databases.use(.postgres(configuration: configuration), as: .psql)
    
    
    app.migrations.add(User())
    app.migrations.add(Book())
    app.migrations.add(Account())
    app.migrations.add(CategoryGroup())
    app.migrations.add(Category())
    app.migrations.add(Transaction())
    app.migrations.add(TransactionDetail())
    app.migrations.add(TransactionDetailSplit())
    
    try await app.autoMigrate()
    
    try routes(app)
}
