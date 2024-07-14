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
        
//        try books.grouped(UserAuthenticator()).group(":id") { book throws in
//            book.get(use: show)
//            book.delete(use: delete)
//        }
    }

    ///Create book
    ///`{ "name": String }`
    ///`POST: /api/book`
    @Sendable func create(req: Request) async throws -> Book {
        guard let bookName: String = req.content["name"],
              !bookName.isOnlySpacesOrEmpty else {
            throw Abort(.badRequest, reason: "Book name should not be empty")
        }
        
        let userID = try req.auth.require(User.self).id!
        
        let book = Book(name: bookName, userid: userID)

        try await book.create(on: req.db)
        
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

//    ///Update password
//    ///`{ "original": String, "new": String }`
//    @Sendable func update(req: Request) async throws -> String {
//        guard let todo = try await Todo.find(req.parameters.get("id"), on: req.db) else {
//            throw Abort(.notFound)
//        }
//        let updatedTodo = try req.content.decode(Todo.self)
//        todo.title = updatedTodo.title
//        try await todo.save(on: req.db)
//        return todo
//    }

//    ///Delete a user based on userid
//    ///Only admin user or user self can delete user
//    ///Delete operation is soft delete
//    @Sendable func delete(req: Request) async throws -> HTTPStatus {
//        let operatorUser = try req.auth.require(User.self)
//        
//        guard let deletionID = req.parameters.get("id") else {
//            throw Abort(.badRequest, reason: "A delete id is required for delete operation")
//        }
//        
//        guard let deletionUUID = UUID(uuidString: deletionID) else {
//            throw Abort(.internalServerError, reason: "deletion id passed is not a UUID")
//        }
//        
//        let deletionUser = try await findUser(id: deletionUUID, req: req)
//        
//        guard !deletionUser.admin else {
//            throw Abort(.badRequest, reason: "Admin user cannot be deleted")
//        }
//        
//        guard operatorUser.admin == true || operatorUser.id == deletionUUID else {
//            throw Abort(.unauthorized, reason: "You don't have permisson to delete user.")
//        }
//        try await deletionUser.delete(on: req.db)
//        return .ok
//    }
//        
//    private func findUser(id: UUID, req: Request) async throws -> User {
//        guard let user = try await User.find(id, on: req.db) else {
//            throw Abort(.notFound, reason: "User not found")
//        }
//        return user
//    }
}

