//
//  Account.swift
//
//
//  Created by Shibo Tong on 14/7/2024.
//

import Foundation
import Vapor
import Fluent
import SQLKit

final class Account: Model, Content, @unchecked Sendable {
    
    static let schema = "account"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "account_name")
    var accountName: String
    
    @Field(key: "currency")
    var currency: String
    
    @Parent(key: "book_id")
    var book: Book
    
    @Children(for: \.$account)
    var transactionDetails: [TransactionDetail]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(id: Int? = nil, name: String, currency: String, bookid: Int) {
        self.id = id
        self.accountName = name
        self.currency = currency
        self.$book.id = bookid
    }
}


extension Account: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Self.schema)
            .field("id", .int, .identifier(auto: true))
            .field("account_name", .string, .required)
            .field("currency", .string, .required)
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
