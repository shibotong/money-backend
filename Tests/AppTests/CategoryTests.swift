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
        
        try await self.app.test(.POST, "pi/users/\(userid!)/category")
    }

    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        try await removeDatabase(dbName: databaseName, username: dbUserName)
        self.app = nil
    }

    func testCreate() async throws {
        let categoryName = "testcategory"
        
        try await createCategory(userid!, categoryName) { res async throws in
            XCTAssertEqual(res.status, .ok)
            let category = try res.content.decode(Category.self)
            XCTAssertEqual(category.name, "testcategory")
            XCTAssertEqual(category.userid?.uuidString, self.userid)
        }
        
        try await createCategory(fakeUserID, categoryName) { res async throws in
            XCTAssertEqual(res.status, .badRequest)
        }
        
        try await createCategory(userid!, "  ") { res async throws in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testUpdate() async throws {
        let updatedName = "updatedname"
        guard let categoryID = try await createCategory(userid!, updatedName) else {
            XCTFail()
            return
        }
        
        try await updateCategory(userid!, categoryID, updatedName) { res in
            XCTAssertEqual(res.status, .ok)
            let category = try res.content.decode(Category.self)
            XCTAssertEqual(category.name, updatedName)
            XCTAssertEqual(category.userid?.uuidString, userid)
        }
        
        try await updateCategory(fakeUserID, categoryID, updatedName) { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
        
        try await updateCategory(userid!, 4, updatedName) { res in
            XCTAssertEqual(res.status, .notFound)
        }
        
        try await updateCategory(userid!, categoryID, "  ") { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    @discardableResult
    private func createCategory(_ userid: String, _ name: String, testcases: ((XCTHTTPResponse) async throws -> ())? = nil) async throws -> Int? {
        var categoryID: Int?
        try await self.app.test(.POST, "api/users/\(userid)/category", beforeRequest: { req in
            try req.content.encode(["name": name])
        }) { res async throws in
            try await testcases?(res)
            let category = try? res.content.decode(Category.self)
            categoryID = category?.id
        }
        
        return categoryID
    }
    
    private func updateCategory(_ userid: String, _ categoryID: Int, _ name: String, _ testcases: (XCTHTTPResponse) throws -> ()) async throws {
        try await self.app.test(.PUT, "api/users/\(userid)/category/\(categoryID)", beforeRequest: { req in
            try req.content.encode(["name": name])
        }) { res async throws in
            try testcases(res)
        }
    }
}
