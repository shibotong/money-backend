//
//  User.swift
//
//
//  Created by Shibo Tong on 20/6/2024.
//

import Foundation
import Vapor
import Fluent
import SQLKit

final class User: Model, Content, Authenticatable, @unchecked Sendable {
    
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
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, username: String, password: String, currency: String = "USD", admin: Bool = false) {
        self.id = id
        self.username = username
        self.password = password
        self.currency = currency
        self.admin = admin
    }
}

extension User: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Self.schema)
            .id()
            .field("username", .string, .required)
            .unique(on: "username")
            .field("password", .string, .required)
            .field("currency", .string)
            .field("admin", .bool, .required, .sql(.default(false)))
            .field("created_at", .datetime, .required, .sql(.default(SQLFunction("now"))))
            .field("updated_at", .datetime, .required, .sql(.default(SQLFunction("now"))))
            .field("deleted_at", .datetime)
            .ignoreExisting()
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Self.schema).delete()
    }
}
