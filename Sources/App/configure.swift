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
                                                 username: "money_app",
                                                 password: "money_app",
                                                 database: "money-app",
                                                 tls: .disable)
    
    app.databases.use(.postgres(configuration: configuration), as: .psql)
    
    try routes(app)
}
//
//func createUserTable() async  {
//    try await database.schema("planets")
//        .id()
//        .field("name", .string, .required)
//        .field("star_id", .uuid, .required, .references("stars", "id"))
//        .create()
//}
