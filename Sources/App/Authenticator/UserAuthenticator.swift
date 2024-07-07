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
        request.auth.login(user)
    }
    
    
    
}
