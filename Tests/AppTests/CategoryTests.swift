////
////  CategoryTests.swift
////  
////
////  Created by Shibo Tong on 7/7/2024.
////
//@testable import App
//import XCTVapor
//import FluentPostgresDriver
//
//final class CategoryTests: XCTestCase {
//    
//    var app: Application!
//    var databaseName: String!
//    var databaseId: DatabaseID { DatabaseID(string: databaseName) }
//    var dbUserName: String!
//    
//    var username: String!
//    var password: String!
//    var userid: String!
//
//    override func setUp() async throws {
//        username = "username_\(String.random(length: 5))"
//        password = "password_\(String.random(length: 5))"
//        
//        databaseName = "database_\(String.random(length: 10))".lowercased()
//        dbUserName = "testuser_\(String.random(length: 10))"
//        let dbPassword = "password_\(String.random(length: 10))"
//        app = try await setupDatabase(dbName: databaseName, username: dbUserName, password: dbPassword)
//        
//        try super.setUpWithError()
//        
//        try await self.app.test(.POST, "api/users", beforeRequest: { req in
//            try req.content.encode(["username": username, "password": password])
//        }, afterResponse: { res async throws in
//            userid = res.body.string
//        })
//    }
//
//    override func tearDown() async throws {
//        try await self.app.asyncShutdown()
//        try await removeDatabase(dbName: databaseName, username: dbUserName)
//        self.app = nil
//    }
//
//    func testCreate() async throws {
//        let categoryName = "testcategory"
//        
//        try await createCategory(userid!, categoryName) { res async throws in
//            XCTAssertEqual(res.status, .ok)
//            let category = try res.content.decode(Category.self)
//            XCTAssertEqual(category.name, "testcategory")
//            XCTAssertEqual(category.userid?.uuidString, self.userid)
//        }
//        
//        try await createCategory(fakeUserID, categoryName) { res async throws in
//            XCTAssertEqual(res.status, .unauthorized)
//        }
//        
//        try await createCategory(userid!, "  ") { res async throws in
//            XCTAssertEqual(res.status, .badRequest)
//        }
//    }
//    
//    func testUpdate() async throws {
//        let updatedName = "updatedname"
//        guard let categoryID = try await createCategory(userid!, "categoryName") else {
//            XCTFail()
//            return
//        }
//        
//        try await updateCategory(userid!, categoryID, updatedName) { res in
//            XCTAssertEqual(res.status, .ok)
//            let category = try res.content.decode(Category.self)
//            XCTAssertEqual(category.name, updatedName)
//            XCTAssertEqual(category.userid?.uuidString, userid)
//        }
//        
//        try await updateCategory(fakeUserID, categoryID, updatedName) { res in
//            XCTAssertEqual(res.status, .unauthorized)
//        }
//        
//        try await updateCategory(userid!, 4, updatedName) { res in
//            XCTAssertEqual(res.status, .notFound)
//        }
//        
//        try await updateCategory(userid!, categoryID, "  ") { res in
//            XCTAssertEqual(res.status, .badRequest)
//        }
//    }
//    
//    func testRead() async throws {
//        let categoryName1 = "testcategory1"
//        let categoryName2 = "testcategory2"
//        guard let categoryID = try await createCategory(userid!, categoryName1) else {
//            XCTFail()
//            return
//        }
//        
//        guard let categoryID2 = try await createCategory(userid!, categoryName2) else {
//            XCTFail()
//            return
//        }
//        
//        try await self.app.test(.GET, "api/category", headers: authorization(token: userid!)) { res async throws in
//            let categories = try res.content.decode([App.Category].self)
//            XCTAssertEqual(categories.count, 2)
//        }
//        
//        try await self.app.test(.GET, "api/category/\(categoryID)", headers: authorization(token: userid!)) { res async throws in
//            let category = try res.content.decode(App.Category.self)
//            XCTAssertEqual(category.name, categoryName1)
//            XCTAssertEqual(category.userid?.uuidString, userid)
//        }
//        
//    }
//    
//    @discardableResult
//    private func createCategory(_ userid: String, _ name: String, testcases: ((XCTHTTPResponse) async throws -> ())? = nil) async throws -> Int? {
//        var categoryID: Int?
//        try await self.app.test(.POST, "api/category", headers: authorization(token: userid), beforeRequest: { req in
//            try req.content.encode(["name": name])
//        }) { res async throws in
//            try await testcases?(res)
//            let category = try? res.content.decode(Category.self)
//            categoryID = category?.id
//        }
//        
//        return categoryID
//    }
//    
//    private func updateCategory(_ userid: String, _ categoryID: Int, _ name: String, _ testcases: (XCTHTTPResponse) throws -> ()) async throws {
//        try await self.app.test(.PUT, "api/category/\(categoryID)", headers: authorization(token: userid), beforeRequest: { req in
//            try req.content.encode(["name": name])
//        }) { res async throws in
//            try testcases(res)
//        }
//    }
//}
