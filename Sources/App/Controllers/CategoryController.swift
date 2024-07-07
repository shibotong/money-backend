//
//  File.swift
//  
//
//  Created by Shibo Tong on 7/7/2024.
//

import Foundation
import Vapor
import PostgresNIO

///This controller contains all routes related to user, including create, update, delete users
struct CategoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let categories = routes.grouped("category")
        categories.group(":name") { category in
            category.post(use: create)
        }
    }
    
    ///Create category
    @Sendable func create(req: Request) async throws -> HTTPStatus {
        guard let useridString = req.parameters.get("id"),
              let userid = UUID(uuidString: useridString),
              let categoryName = req.parameters.get("name") else {
            throw Abort(.badRequest, reason: "Userid or category name should not be empty")
        }
        
        let category = Category(name: categoryName, userid: userid)

        do {
            try await category.create(on: req.db)
        } catch let error as PSQLError {
            throw Abort(.badRequest, reason: error.serverInfo?[.message])
        }
        
        return .ok
    }
}
