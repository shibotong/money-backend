//
//  Category.swift
//
//
//  Created by Shibo Tong on 5/7/2024.
//

import Foundation
import Vapor
import Fluent
import SQLKit

final class Category: Model, Content, @unchecked Sendable {
    
    static let schema = "category"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "category_name")
    var categoryName: String
    
    @Field(key: "book_id")
    var bookid: Int?
    
    @Field(key: "parent_category_id")
    var parentCategoryID: Int?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(id: Int? = nil, name: String, bookid: Int? = nil, parentCategoryID: Int? = nil) {
        self.id = id
        self.categoryName = name
        self.bookid = bookid
        self.parentCategoryID = parentCategoryID
    }
}


extension Category: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Self.schema)
            .field("id", .int, .identifier(auto: true))
            .field("category_name", .string, .required)
            .field("book_id", .int, .required, .references("book", "id"))
            .field("parent_category_id", .int, .references("category", "id"))
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
