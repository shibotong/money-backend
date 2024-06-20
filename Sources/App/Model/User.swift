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
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "currency")
    var currency: String?
    
    @Field(key: "admin")
    var admin: Bool?
    
    init() {}
    
    init(id: UUID? = nil, name: String, password: String, currency: String = "USD", admin: Bool = false) {
        self.id = id
        self.name = name
        self.password = password
        self.currency = currency
        self.admin = admin
    }
}

struct LoginUser: Content {
    var id: UUID?
    var name: String
    var currency: String?
    var admin: Bool
    
    init(from user: User) {
        id = user.id
        name = user.name
        currency = user.currency
        admin = user.admin ?? false
    }
}
