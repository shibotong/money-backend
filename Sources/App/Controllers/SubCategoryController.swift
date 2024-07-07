//
//  File.swift
//  
//
//  Created by Shibo Tong on 7/7/2024.
//

import Foundation
import Vapor
import PostgresNIO

///This controller contains all routes related to sub-category, including create, update, delete users
struct SubCategoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let categories = routes.grouped("subcategory")
        categories.post(use: create)
//        categories.group(":subcategoryid") { category in
//            category.put(use: update)
//        }
    }
    
    ///Create category
    ///`{ "name": String }`
    @Sendable func create(req: Request) async throws -> SubCategory {
        let userid = try req.auth.require(User.self).id
        guard let categoryIDString = req.parameters.get("categoryid"),
              let subCategoryName: String = req.content["name"] else {
            throw Abort(.badRequest, reason: "subcategory name should not be empty")
        }
        
        guard isValidName(subCategoryName) else {
            throw Abort(.badRequest, reason: "subcategory name is not valid")
        }
        
        guard let categoryID = Int(categoryIDString),
              let category = try? await Category.find(categoryID, on: req.db) else {
            throw Abort(.notFound, reason: "Category not found")
        }
        
        guard category.userid == userid else {
            throw Abort(.unauthorized)
        }
        let subCategory = SubCategory(name: subCategoryName, categoryID: categoryID)

        do {
            try await subCategory.create(on: req.db)
        } catch let error as PSQLError {
            throw Abort(.badRequest, reason: error.serverInfo?[.message])
        }
        
        return subCategory
    }
    
//    @Sendable func update(req: Request) async throws -> Category {
//        guard let categoryIDString = req.parameters.get("categoryid") else {
//            throw Abort(.badRequest, reason: "Category ID is need for update")
//        }
//        
//        guard let categoryID = Int(categoryIDString) else {
//            throw Abort(.badRequest, reason: "Invalid category ID")
//        }
//        
//        guard let category = try await Category.find(categoryID, on: req.db) else {
//            throw Abort(.notFound, reason: "Category with id \(categoryID) not found")
//        }
//        
//        guard let useridString = req.parameters.get("id"),
//              let userid = UUID(uuidString: useridString) else {
//            throw Abort(.badRequest, reason: "A userid is needed for update")
//        }
//        let updatedCategory = try req.content.decode(Category.self)
//        guard userid == category.userid else {
//            throw Abort(.unauthorized, reason: "Only category owner can update the category name")
//        }
//        
//        guard isValidName(updatedCategory.name) else {
//            throw Abort(.badRequest, reason: "updated name is not valid")
//        }
//        
//        category.name = updatedCategory.name
//        try await category.save(on: req.db)
//        return category
//    }
    
    private func isValidName(_ str: String) -> Bool {
        return !str.isEmpty && !str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
