//
//  Book.swift
//
//
//  Created by Shibo Tong on 14/7/2024.
//

import Foundation
import Vapor
import Fluent
import SQLKit

final class Book: Model, Content, @unchecked Sendable {
    
    static let schema = "book"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "book_name")
    var bookName: String
    
    @Field(key: "userid")
    var userid: UUID
    
    @Children(for: \.$book)
    var accounts: [Account]
    
    @Children(for: \.$book)
    var categoryGroups: [CategoryGroup]
    
    @Children(for: \.$book)
    var transactions: [Transaction]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(id: Int? = nil, name: String, userid: UUID) {
        self.id = id
        self.bookName = name
        self.userid = userid
    }
}


extension Book: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Self.schema)
            .field("id", .int, .identifier(auto: true))
            .field("book_name", .string, .required)
            .field("userid", .uuid, .required, .references("users", "id"))
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
