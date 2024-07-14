//
//  UserController.swift
//
//
//  Created by Shibo Tong on 4/7/2024.
//

import Vapor
import Fluent

///This controller contains all routes related to user, including create, update, delete users
struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: create)
        
        try users.grouped(UserAuthenticator()).group(":id") { user throws in
            user.get(use: show)
            user.delete(use: delete)
        }
    }

    ///Create user
    ///`{ "username": String, "password": String }`
    ///`POST: /api/users`
    @Sendable func create(req: Request) async throws -> String {
        guard let username: String = req.content["username"],
                let password: String = req.content["password"],
              (!username.isOnlySpacesOrEmpty && !password.isOnlySpacesOrEmpty) else {
            throw Abort(.badRequest, reason: "Username or password should not be empty")
        }
        
        
        let user = User(username: username, password: password)
        let isNewDatabase = try await User.query(on: req.db).count() == 0
        user.admin = isNewDatabase
        
        if !isNewDatabase, try await User.query(on: req.db).filter(\.$username == user.username).first() != nil {
            throw Abort(.conflict, reason: "Username '\(username)' is already taken.")
        }

        try await user.create(on: req.db)
        
        guard let userid = user.id else {
            throw Abort(.internalServerError, reason: "Fail to create user.")
        }
        return userid.uuidString
    }
    
    @Sendable func show(req: Request) async throws -> String {
        guard let userid = req.parameters.get("id"),
              let uuid = UUID(uuidString: userid) else {
            throw Abort(.badRequest, reason: "Id is required for this operation")
        }
        
        let user = try await findUser(id: uuid, req: req)
        
        var result: [String: Any] = ["username": user.username, "admin": user.admin]
        if let deletedAt = user.deletedAt {
            result["deletedAt"] = deletedAt
        }
        return try jsonString(result)
    }

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

    ///Delete a user based on userid
    ///Only admin user or user self can delete user
    ///Delete operation is soft delete
    @Sendable func delete(req: Request) async throws -> HTTPStatus {
        let operatorUser = try req.auth.require(User.self)
        
        guard let deletionID = req.parameters.get("id") else {
            throw Abort(.badRequest, reason: "A delete id is required for delete operation")
        }
        
        guard let deletionUUID = UUID(uuidString: deletionID) else {
            throw Abort(.internalServerError, reason: "deletion id passed is not a UUID")
        }
        
        let deletionUser = try await findUser(id: deletionUUID, req: req)
        
        guard !deletionUser.admin else {
            throw Abort(.badRequest, reason: "Admin user cannot be deleted")
        }
        
        guard operatorUser.admin == true || operatorUser.id == deletionUUID else {
            throw Abort(.unauthorized, reason: "You don't have permisson to delete user.")
        }
        try await deletionUser.delete(on: req.db)
        return .ok
    }
        
    private func findUser(id: UUID, req: Request) async throws -> User {
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        return user
    }
}
