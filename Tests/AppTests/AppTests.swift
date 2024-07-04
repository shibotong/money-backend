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
    var dbUserName: String!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        databaseName = "database_\(String.random(length: 10))".lowercased()
        
        let postgres = app.db(.psql) as! PostgresDatabase
        
        dbUserName = "testuser_\(String.random(length: 10))"
        let password = "password_\(String.random(length: 10))"
        
        _ = try await postgres.simpleQuery("CREATE USER \(dbUserName!) WITH PASSWORD '\(password)'").get()
        _ = try await postgres.simpleQuery("CREATE DATABASE \(databaseName!)").get()
        _ = try await postgres.simpleQuery("ALTER DATABASE \(databaseName!) OWNER TO \(dbUserName!)").get()
        
        let configuration = SQLPostgresConfiguration(hostname: "localhost",
                                                     port: SQLPostgresConfiguration.ianaPortNumber,
                                                     username: dbUserName,
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
        _ = try await postgres.simpleQuery("DROP USER IF EXISTS \(dbUserName!)").get()
        print("Drop user \(dbUserName!)")
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
        
        let username1 = "username1"
        let password1 = "password1"
        
        let username2 = "username2"
        let password2 = "password2"
        
        var userid1: String!
        var userid2: String!
        
        // Create user 1
        try await self.app.test(.POST, "api/users", beforeRequest: { req in
            try req.content.encode(["name": username1, "password": password1])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(LoginUser.self)
            XCTAssertTrue(user.admin)
            XCTAssertEqual(user.name, username1)
            XCTAssertNotNil(user.id)
            userid1 = user.id!.description
        })
        
        // Create user 2
        try await self.app.test(.POST, "api/users", beforeRequest: { req in
            try req.content.encode(["name": username2, "password": password2])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(LoginUser.self)
            XCTAssertFalse(user.admin)
            XCTAssertEqual(user.name, username2)
            XCTAssertNotNil(user.id)
            userid2 = user.id!.description
        })
        
        // login with fail password
        try await self.app.test(.POST, "api/login", beforeRequest: { req in
            try req.content.encode(["name": username1, "password": "wrongpassword"])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .unauthorized)
        })
        
        // login user 1
        try await self.app.test(.POST, "api/login", beforeRequest: { req in
            try req.content.encode(["name": username1, "password": password1])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(LoginUser.self)
            XCTAssertEqual(userid1, user.id?.description)
            XCTAssertTrue(user.admin)
            XCTAssertEqual(user.name, username1)
        })
        
        // login user 2
        try await self.app.test(.POST, "api/login", beforeRequest: { req in
            try req.content.encode(["name": username2, "password": password2])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(LoginUser.self)
            XCTAssertEqual(userid2, user.id?.description)
            XCTAssertFalse(user.admin)
            XCTAssertEqual(user.name, username2)
        })
        
        
    }
}
