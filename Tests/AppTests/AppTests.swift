@testable import App
import XCTVapor
import FluentPostgresDriver

extension String {
    /// Generates a random string with given length
    ///
    /// - Source: [StackOverflow](https://stackoverflow.com/a/26845710)
    /// - License: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
    static func random(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
      return String((0..<length).map { _ in letters.randomElement()! })
    }
}

final class AppTests: XCTestCase {
    var app: Application!
    var databaseName: String!
    var databaseId: DatabaseID { DatabaseID(string: databaseName) }
    var username: String!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        databaseName = "database_\(String.random(length: 10))".lowercased()
        
        let postgres = app.db(.psql) as! PostgresDatabase
        
        username = "testuser_\(String.random(length: 10))"
        let password = "password_\(String.random(length: 10))"
        
        _ = try await postgres.simpleQuery("CREATE USER \(username!) WITH PASSWORD '\(password)'").get()
        _ = try await postgres.simpleQuery("CREATE DATABASE \(databaseName!)").get()
        _ = try await postgres.simpleQuery("ALTER DATABASE \(databaseName!) OWNER TO \(username!)").get()
//        _ = try await postgres.simpleQuery("GRANT ALL PRIVILEGES ON DATABASE \(databaseName!) to \(username!)").get()
//        _ = try await postgres.simpleQuery("GRANT ALL ON SCHEMA public TO EXAMPLE_USER").get()
//        _ = postgres.simpleQuery("CREATE USER \(username!) WITH PASSWORD '\(password)'")
//        _ = postgres.simpleQuery("CREATE DATABASE \(databaseName!)")
//        _ = postgres.simpleQuery("GRANT ALL PRIVILEGES ON DATABASE \(databaseName!) to \(username!)")
        
        let configuration = SQLPostgresConfiguration(hostname: "localhost",
                                                     port: SQLPostgresConfiguration.ianaPortNumber,
                                                     username: username,
                                                     password: password,
                                                     database: databaseName,
                                                     tls: .disable)
        app.databases.use(
            .postgres(configuration: configuration),
            as: databaseId
        )
        app.databases.default(to: databaseId)
        let testDB = app.db(databaseId) as! PostgresDatabase
        try await initService(testDB)
        try await app.autoMigrate().get()
        
        try super.setUpWithError()
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        
        let clearDatabaseApp = try await Application.make(.testing)
        try await configure(clearDatabaseApp)
        let postgres = clearDatabaseApp.db(.psql) as! PostgresDatabase
        _ = try await postgres.simpleQuery("DROP DATABASE \(databaseName!)").get()
        print("Drop database \(databaseName!)")
        _ = try await postgres.simpleQuery("DROP USER IF EXISTS \(username!)").get()
        print("Drop user \(username!)")
        try await clearDatabaseApp.asyncShutdown()
        
        self.app = nil
    }
    
    func testConnection() async throws {
        try await self.app.test(.GET, "hello") { res async in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "hello world!")
        }
    }
    
    func testUser() async throws {
        var userid: String!
        
        try await self.app.test(.POST, "api/users", beforeRequest: { req in
            try req.content.encode(["name": "testuser", "password": "testpassword"])
        }, afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            userid = res.body.string
        })
        
        try await self.app.test(.GET, "api/user/\(userid!)") { res async in
            XCTAssertEqual(res.body.string, "")
        }
    }
}
