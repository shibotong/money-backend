//
//  User.swift
//
//
//  Created by Shibo Tong on 20/6/2024.
//

import Foundation
import Vapor
import Fluent

final class User: Model, Content {
    
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "currency")
    var currency: String?
    
    @Field(key: "admin")
    var admin: Bool
    
    @Field(key: "deleted")
    var deleted: Bool
    
    init() {}
    
    init(id: UUID? = nil, username: String, password: String, currency: String = "USD", admin: Bool = false, deleted: Bool = false) {
        self.id = id
        self.username = username
        self.password = password
        self.currency = currency
        self.admin = admin
        self.deleted = deleted
    }
}

struct LoginUser: Content {
    var id: UUID?
    var username: String
    var currency: String?
    var admin: Bool
    
    init(from user: User) {
        id = user.id
        username = user.username
        currency = user.currency
        admin = user.admin ?? false
    }
}
