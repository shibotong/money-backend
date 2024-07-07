//
//  File.swift
//  
//
//  Created by Shibo Tong on 7/7/2024.
//

import Foundation
import Vapor
import PostgresNIO
import Fluent

///This controller contains all routes related to category, including create, update, delete users
struct CategoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let categories = routes.grouped(UserAuthenticator()).grouped("category")
        categories.post(use: create)
        categories.get(use: show)
        try categories.group(":categoryid") { category throws in
            category.put(use: update)
            category.get(use: showSingle)
            try category.register(collection: SubCategoryController())
        }
    }
    
    ///Create category
    ///`{ "name": String }`
    @Sendable func create(req: Request) async throws -> Category {
        guard let categoryName: String = req.content["name"] else {
            throw Abort(.badRequest, reason: "Userid or category name should not be empty")
        }
        let userid = try req.auth.require(User.self).id
        guard isValidName(categoryName) else {
            throw Abort(.badRequest, reason: "category name is not valid")
        }
        
        let category = Category(name: categoryName, userid: userid)

        do {
            try await category.create(on: req.db)
        } catch let error as PSQLError {
            throw Abort(.badRequest, reason: error.serverInfo?[.message])
        }
        
        return category
    }
    
    @Sendable func update(req: Request) async throws -> Category {
        guard let categoryIDString = req.parameters.get("categoryid") else {
            throw Abort(.badRequest, reason: "Category ID is need for update")
        }
        
        guard let categoryID = Int(categoryIDString) else {
            throw Abort(.badRequest, reason: "Invalid category ID")
        }
        
        guard let category = try await Category.find(categoryID, on: req.db) else {
            throw Abort(.notFound, reason: "Category with id \(categoryID) not found")
        }
        
        guard let useridString = req.parameters.get("id"),
              let userid = UUID(uuidString: useridString) else {
            throw Abort(.badRequest, reason: "A userid is needed for update")
        }
        let updatedCategory = try req.content.decode(Category.self)
        guard userid == category.userid else {
            throw Abort(.unauthorized, reason: "Only category owner can update the category name")
        }
        
        guard isValidName(updatedCategory.name) else {
            throw Abort(.badRequest, reason: "updated name is not valid")
        }
        
        category.name = updatedCategory.name
        try await category.save(on: req.db)
        return category
    }
    
    @Sendable func show(req: Request) async throws -> [Category] {
        let userid = try req.auth.require(User.self).id
        let categories = try await Category.query(on: req.db).filter(\.$userid == userid).with(\.$subCategories).all()
        return categories
    }
    
    @Sendable func showSingle(req: Request) async throws -> Category {
        let userid = try req.auth.require(User.self).id
        guard let categoryIDString = req.parameters.get("categoryid"),
              let categoryID = Int(categoryIDString) else {
            throw Abort(.badRequest)
        }
        
        guard let category = try await Category.find(categoryID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard category.userid == userid else {
            throw Abort(.unauthorized)
        }
        
        return category
    }
    
    private func isValidName(_ str: String) -> Bool {
        return !str.isEmpty && !str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
