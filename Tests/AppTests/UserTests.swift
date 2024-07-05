@testable import App
import XCTVapor
import FluentPostgresDriver

final class UserTests: XCTestCase {
    var app: Application!
    var databaseName: String!
    var databaseId: DatabaseID { DatabaseID(string: databaseName) }
    var dbUserName: String!
    
    var username: String!
    var password: String!
    var userid: String!
    
    override func setUp() async throws {
        
        username = "username_\(String.random(length: 5))"
        password = "password_\(String.random(length: 5))"
        
        databaseName = "database_\(String.random(length: 10))".lowercased()
        dbUserName = "testuser_\(String.random(length: 10))"
        let dbPassword = "password_\(String.random(length: 10))"
        app = try await setupDatabase(dbName: databaseName, username: dbUserName, password: dbPassword)
        
        try super.setUpWithError()
        
        try await self.app.test(.POST, "api/users", beforeRequest: { req in
            try req.content.encode(["username": username, "password": password])
        }, afterResponse: { res async throws in
            userid = res.body.string
        })
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        try await removeDatabase(dbName: databaseName, username: dbUserName)
        self.app = nil
    }
    
    func testCreateUser() async throws {
        
        let username2 = "username2"
        let password2 = "password2"
        
        var userid2: String!
        
        // Create user
        try await self.app.test(.POST, "api/users", beforeRequest: { req in
            try req.content.encode(["username": username2, "password": password2])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            XCTAssertFalse(res.body.string.isEmpty)
            userid2 = res.body.string
        })
        
        
        // fetch user 1
        try await self.app.test(.GET, "api/users/\(userid!)") { res async throws in
            let result = res.body.string.dictionaryValue
            XCTAssertEqual(result["username"] as? String, username)
            XCTAssertEqual(result["admin"] as? Bool, true)
            XCTAssertEqual(result["deleted"] as? Bool, false)
        }
        
        // fetch user 2
        try await self.app.test(.GET, "api/users/\(userid2!)") { res async throws in
            let result = res.body.string.dictionaryValue
            XCTAssertEqual(result["username"] as? String, username2)
            XCTAssertEqual(result["admin"] as? Bool, false)
            XCTAssertEqual(result["deleted"] as? Bool, false)
        }
    }
    
    func testLogin() async throws {
        // login with wrong password
        try await self.app.test(.POST, "api/login", beforeRequest: { req in
            try req.content.encode(["username": username, "password": "wrongpassword"])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .unauthorized)
        })
        
        // login with correct password
        try await self.app.test(.POST, "api/login", beforeRequest: { req in
            try req.content.encode(["username": username, "password": password])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(userid, res.body.string)
        })
    }
}
