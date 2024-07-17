//
//  UserAuthenticator.swift
//
//
//  Created by Shibo Tong on 7/7/2024.
//

import Foundation
import Vapor

struct UserAuthenticator: AsyncBearerAuthenticator {
    func authenticate(bearer: Vapor.BearerAuthorization, for request: Vapor.Request) async throws {
        let token = bearer.token
        guard let user = try await User.find(UUID(uuidString: token), on: request.db) else {
            throw Abort(.unauthorized, reason: "not authorized")
        }
        
        if let bookidString = request.parameters.get("bookid"),
           let bookID = Int(bookidString) {
            // authenticate book
            guard let book = try await Book.find(bookID, on: request.db) else {
                throw Abort(.notFound, reason: "Book not found")
            }
            
            guard book.userid == user.id else {
                throw Abort(.unauthorized, reason: "The book is not belong to user")
            }
        }
        
        request.auth.login(user)
    }
}
