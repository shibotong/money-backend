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
    
    @Field(key: "bookid")
    var bookid: Int?
    
    @Timestamp(key: "created_at", on: .create)
    var createAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(id: Int? = nil, name: String, currency: String, bookid: Int? = nil) {
        self.id = id
        self.accountName = name
        self.currency = currency
        self.bookid = bookid
    }
}


extension Account: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Self.schema)
            .field("id", .int, .identifier(auto: true))
            .field("account_name", .string, .required)
            .field("currency", .string, .required)
            .field("bookid", .int, .required, .references("book", "id"))
            .field("created_at", .datetime, .required, .sql(.default(SQLFunction("now"))))
            .field("deleted_at", .datetime)
            .ignoreExisting()
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Self.schema).delete()
    }
}
