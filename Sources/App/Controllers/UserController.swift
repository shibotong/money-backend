//
//  UserController.swift
//
//
//  Created by Shibo Tong on 4/7/2024.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: create)

//        todos.group(":id") { todo in
//            todo.get(use: show)
//            todo.put(use: update)
//            todo.delete(use: delete)
//        }
    }

    @Sendable func create(req: Request) async throws -> String {
        let user = try req.content.decode(User.self)
        let newDB = try await User.query(on: req.db).count() == 0
        user.admin = newDB
        
        if !newDB, try await User.query(on: req.db).filter(\.$name == user.name).first() != nil {
            throw MoneyErrors.duplicatedUser(user.name)
        }

        try await user.create(on: req.db)
        guard let userID = user.id else {
            throw MoneyErrors.failedCreateUser
        }
        return userID.description
    }

//    func update(req: Request) async throws -> Todo {
//        guard let todo = try await Todo.find(req.parameters.get("id"), on: req.db) else {
//            throw Abort(.notFound)
//        }
//        let updatedTodo = try req.content.decode(Todo.self)
//        todo.title = updatedTodo.title
//        try await todo.save(on: req.db)
//        return todo
//    }

//    func delete(req: Request) async throws -> HTTPStatus {
//        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
//            throw Abort(.notFound)
//        }
//        try await user.delete(on: req.db)
//        return .ok
//    }
}
