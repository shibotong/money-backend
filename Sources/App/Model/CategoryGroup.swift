//
//  CategoryGroup.swift
//
//
//  Created by Shibo Tong on 17/7/2024.
//

import Foundation
import Vapor
import Fluent
import SQLKit

final class CategoryGroup: Model, Content, @unchecked Sendable {
    
    static let schema = "category_group"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "category_group_name")
    var categoryGroupName: String
    
    @Field(key: "is_expense")
    var isExpense: Bool
    
    @Parent(key: "book_id")
    var book: Book
    
    @Children(for: \.$categoryGroup)
    var categories: [Category]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(id: Int? = nil, name: String, isExpense: Bool, bookid: Int) {
        self.id = id
        self.categoryGroupName = name
        self.isExpense = isExpense
        self.$book.id = bookid
    }
    
    static let defaultExpense: [String : [String]] = [
        "Housing": ["Rent", "Repair", "Furniture", "Other"],
        "Food & Drinks": ["Groceries", "Restaurant", "Snacks", "Drinks"],
        "Transportation": ["Parking", "Fuel", "Maintenance", "Public Transport", "Other"],
        "Utilities": ["Gas", "Water", "Electricity", "Cell Phone", "Internet"],
        "Personal": ["Grooming", "Clothing"]
    ]
}


extension CategoryGroup: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Self.schema)
            .field("id", .int, .identifier(auto: true))
            .field("category_group_name", .string, .required)
            .field("is_expense", .bool, .required)
            .field("book_id", .int, .required, .references("book", "id"))
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
