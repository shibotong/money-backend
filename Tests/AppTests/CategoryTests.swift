//
//  CategoryTests.swift
//  
//
//  Created by Shibo Tong on 7/7/2024.
//
@testable import App
import XCTVapor
import FluentPostgresDriver

final class CategoryTests: XCTestCase {
    
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

    func testCreate() async throws {
        try await self.app.test(.POST, "api/users/\(userid!)/category/testcategory") { res async throws in
            XCTAssertEqual(res.status, .ok)
        }
        
        try await self.app.test(.POST, "api/users/\(fakeUserID)/category/testcategory") { res async throws in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
}
