//
//  TransactionDetail.swift
//
//
//  Created by Shibo Tong on 14/7/2024.
//

import Foundation
import Vapor
import Fluent
import SQLKit

final class TransactionDetail: Model, Content, @unchecked Sendable {
    
    static let schema = "transaction_detail"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "amount")
    var amount: Int
    
    @Field(key: "currency")
    var currency: String
    
    @Parent(key: "transaction_id")
    var transaction: Transaction
    
    @Children(for: \.$transactionDetail)
    var transactionDetailSplits: [TransactionDetailSplit]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(id: Int? = nil,
         amount: Int,
         currency: String,
         transactionID: Int) {
        self.id = id
        self.amount = amount
        self.currency = currency
        self.$transaction.id = transactionID
    }
}

extension TransactionDetail: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Self.schema)
            .field("id", .int, .identifier(auto: true))
            .field("amount", .int, .required)
            .field("currency", .int, .required)
            .field("transaction_id", .int, .references("transaction", "id"))
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
