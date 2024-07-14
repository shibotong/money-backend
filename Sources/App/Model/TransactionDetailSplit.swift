//
//  TransactionDetailSplit.swift
//  
//
//  Created by Shibo Tong on 14/7/2024.
//

import Foundation
import Vapor
import Fluent
import SQLKit

final class TransactionDetailSplit: Model, Content {
    
    static let schema = "transaction_detail_split"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "category_id")
    var categoryID: Int
    
    @Field(key: "amount")
    var amount: Int
    
    @Field(key: "transaction_detail_id")
    var transactionDetailID: Int?
    
    @Timestamp(key: "created_at", on: .create)
    var createAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(id: Int? = nil,
         categoryID: Int,
         amount: Int,
         transactionDetailID: Int? = nil) {
        self.id = id
        self.amount = amount
        self.categoryID = categoryID
        self.transactionDetailID = transactionDetailID
    }
}

extension TransactionDetailSplit: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Self.schema)
            .field("id", .int, .identifier(auto: true))
            .field("amount", .int, .required)
            .field("category_id", .int, .required, .references("category", "id"))
            .field("transaction_detail_id", .int, .references("transaction_detail", "id"))
            .field("created_at", .datetime, .required, .sql(.default(SQLFunction("now"))))
            .field("deleted_at", .datetime)
            .ignoreExisting()
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Self.schema).delete()
    }
}
