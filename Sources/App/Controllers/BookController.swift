//
//  BookController.swift
//
//
//  Created by Shibo Tong on 14/7/2024.
//

import Vapor
import Fluent

///This controller contains all routes related to user, including create, update, delete users
struct BookController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let books = routes.grouped(UserAuthenticator()).grouped("book")
        books.post(use: create)
        
        try books.grouped(UserAuthenticator()).group(":bookid") { book throws in
            book.put(use: update)
            book.delete(use: delete)
            try book.register(collection: AccountController())
            try book.register(collection: TransactionController())
        }
    }

    ///Create book
    ///`{ "name": String }`
    ///`POST: /api/book`
    @Sendable func create(req: Request) async throws -> Book {
        guard let bookName: String = req.content["name"],
              !bookName.isOnlySpacesOrEmpty else {
            throw Abort(.badRequest, reason: "Book name should not be empty")
        }
        
        let user = try req.auth.require(User.self)
        
        let book = try await Book.createNewBook(name: bookName, user: user, database: req.db)
        
        return book
    }
    
    ///Update book name
    ///`{ "name": String }`
    @Sendable func update(req: Request) async throws -> Book {
        guard let book = try await Book.find(req.parameters.get("bookid"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard let bookName: String = req.content["name"],
              !bookName.isOnlySpacesOrEmpty else {
            throw Abort(.badRequest, reason: "Book name should not be empty")
        }
        
        book.bookName = bookName
        try await book.save(on: req.db)
        return book
    }
    
//    @Sendable func show(req: Request) async throws -> String {
//        guard let userid = req.parameters.get("id"),
//              let uuid = UUID(uuidString: userid) else {
//            throw Abort(.badRequest, reason: "Id is required for this operation")
//        }
//        
//        let user = try await findUser(id: uuid, req: req)
//        
//        var result: [String: Any] = ["username": user.username, "admin": user.admin]
//        if let deletedAt = user.deletedAt {
//            result["deletedAt"] = deletedAt
//        }
//        return try jsonString(result)
//    }

    ///Delete a book based on userid
    @Sendable func delete(req: Request) async throws -> HTTPStatus {
        let operatorUser = try req.auth.require(User.self)
        
        guard let book = try await Book.find(req.parameters.get("bookid"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard book.userid == operatorUser.id else {
            throw Abort(.unauthorized)
        }
        
        try await book.delete(on: req.db)
        return .ok
    }
}

