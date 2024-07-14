//
//  File.swift
//  
//
//  Created by Shibo Tong on 14/7/2024.
//

@testable import App
import XCTVapor
import FluentPostgresDriver

final class BookTests: XCTestCase {
    var app: Application!
    var databaseName: String!
    var dbUserName: String!
    
    var userid: String!
    var userid2: String!
    
    override func setUp() async throws {
        let username = "username_\(String.random(length: 5))"
        let password = "password_\(String.random(length: 5))"
        
        let username2 = "username_\(String.random(length: 5))"
        let password2 = "password_\(String.random(length: 5))"
        
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
        
        try await self.app.test(.POST, "api/users", beforeRequest: { req in
            try req.content.encode(["username": username2, "password": password2])
        }, afterResponse: { res async throws in
            userid2 = res.body.string
        })
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        try await removeDatabase(dbName: databaseName, username: dbUserName)
        self.app = nil
    }
    
    func testCreateBook() async throws {
        try await self.app.test(.POST, "api/book", headers: authorization(token: userid), beforeRequest: { req in
            try req.content.encode(["name": "book 1"])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let book = try res.content.decode(Book.self)
            XCTAssertEqual(book.bookName, "book 1")
            XCTAssertEqual(book.userid.uuidString, userid)
        })
        
        try await self.app.test(.POST, "api/book", headers: authorization(token: userid), beforeRequest: { req in
            try req.content.encode(["name": " "])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .badRequest)
        })
        
        try await self.app.test(.POST, "api/book", headers: authorization(token: fakeUserID), beforeRequest: { req in
            try req.content.encode(["name": "book 2"])
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .unauthorized)
        })
    }
    
    func testUpdateBook() async throws {
        var bookID: Int?
        try await self.app.test(.POST, "api/book", headers: authorization(token: userid), beforeRequest: { req async throws in
            try req.content.encode(["name": "book 1"])
        }, afterResponse: { res in
            let book = try res.content.decode(Book.self)
            bookID = book.id
        })
        
        try await self.app.test(.PUT, "api/book/\(bookID!)", headers: authorization(token: userid), beforeRequest: { req async throws in
            try req.content.encode(["name": "book 2"])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let book = try res.content.decode(Book.self)
            XCTAssertEqual(book.bookName, "book 2")
            XCTAssertEqual(book.userid.uuidString, userid)
            XCTAssertEqual(book.id, bookID)
        })
        
        try await self.app.test(.PUT, "api/book/10)", headers: authorization(token: userid), beforeRequest: { req async throws in
            try req.content.encode(["name": "book 2"])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
        
        try await self.app.test(.PUT, "api/book/\(bookID!)", headers: authorization(token: userid2), beforeRequest: { req async throws in
            try req.content.encode(["name": "book 2"])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
        })
        
        try await self.app.test(.PUT, "api/book/\(bookID!)", headers: authorization(token: userid), beforeRequest: { req async throws in
            try req.content.encode(["name": "   "])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })
    }
}
