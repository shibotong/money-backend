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
    let postgresql = app.db(.psql) as! PostgresDatabase
    try await initService(postgresql)
    try routes(app)
}

public func initService(_ postgres: PostgresDatabase) async throws {
    _ = try await postgres.simpleQuery("""
                                        CREATE TABLE IF NOT EXISTS users (
                                            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                            username VARCHAR(100) NOT NULL,
                                            password VARCHAR(100) NOT NULL,
                                            currency VARCHAR(3),
                                            admin BOOLEAN NOT NULL DEFAULT false,
                                            deleted_at TIMESTAMP
                                        )
                                        """).get()
    
    _ = try await postgres.simpleQuery("""
                                        CREATE TABLE category (
                                            id SERIAL PRIMARY KEY,
                                            name VARCHAR(255),
                                            userid INT REFERENCES users(id),
                                            deleted_at TIMESTAMP
                                        )
                                        """).get()
}
