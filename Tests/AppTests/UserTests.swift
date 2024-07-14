@testable import App
import XCTVapor
import FluentPostgresDriver

final class UserTests: XCTestCase {
    var app: Application!
    var databaseName: String!
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
        
        try await self.app.test(.POST, "api/users", beforeRequest: { req in
            try req.content.encode(["username": "", "password": password2])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)
        })
        
        try await self.app.test(.POST, "api/users", beforeRequest: { req in
            try req.content.encode(["username": username2, "password": password2])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .conflict)
        })
        
        
        // fetch user 1
        try await self.app.test(.GET, "api/users/\(userid!)") { res async throws in
            let result = res.body.string.dictionaryValue
            XCTAssertEqual(result["username"] as? String, username)
            XCTAssertEqual(result["admin"] as? Bool, true)
            XCTAssertNil(result["deletedAt"])
        }
        
        // fetch user 2
        try await self.app.test(.GET, "api/users/\(userid2!)") { res async throws in
            let result = res.body.string.dictionaryValue
            XCTAssertEqual(result["username"] as? String, username2)
            XCTAssertEqual(result["admin"] as? Bool, false)
            XCTAssertNil(result["deletedAt"])
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
    
    func testDelete() async throws {
        guard let userID = try await createUser(username: "deleteUser", password: "deletePass"),
              let userID2 = try await createUser(username: "deleteUser2", password: "deletePass2") else {
            XCTFail()
            return
        }
        
        try await self.app.test(.DELETE, "api/users/abc", headers: authorization(token: userID)) { res async throws in
            XCTAssertEqual(res.status, .badRequest, "A UUID is required for deletion")
        }
        
        try await self.app.test(.DELETE, "api/users/\(userID2)", headers: authorization(token: userID)) { res async throws in
            XCTAssertEqual(res.status, .unauthorized, "Non admin user is not authorized to delete other user")
        }
        
        try await self.app.test(.DELETE, "api/users/\(fakeUserID)", headers: authorization(token: userid!)) { res async throws in
            XCTAssertEqual(res.status, .notFound, "Delete user not found")
        }
        
        try await self.app.test(.DELETE, "api/users/\(userID)", headers: authorization(token: userID)) { res async throws in
            XCTAssertEqual(res.status, .ok, "Non admin user should be able to delete self")
        }

        try await self.app.test(.DELETE, "api/users/\(userID2)", headers: authorization(token: userid!)) { res async throws in
            XCTAssertEqual(res.status, .ok, "Admin user should be able to delete other user")
        }
        
        // delete admin
        try await self.app.test(.DELETE, "api/users/\(userid!)", headers: authorization(token: userid!)) { res async throws in
            XCTAssertEqual(res.status, .badRequest, "Admin user is not able to be deleted")
        }
    }
                                
    private func createUser(username: String, password: String) async throws -> String? {
        var userID: String?
        try await self.app.test(.POST, "api/users", beforeRequest: { req in
            try req.content.encode(["username": username, "password": password])
        }, afterResponse: { res async throws in
            userID = res.body.string
        })
        return userID
    }
}
