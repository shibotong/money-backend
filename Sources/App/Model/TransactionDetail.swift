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
    
    @OptionalParent(key: "account_id")
    var account: Account?
    
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
         transactionID: Int,
         accountID: Int? = nil) {
        self.id = id
        self.amount = amount
        self.$transaction.id = transactionID
        self.$account.id = accountID
    }
}

extension TransactionDetail: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Self.schema)
            .field("id", .int, .identifier(auto: true))
            .field("amount", .int, .required)
            .field("account_id", .int, .references("account", "id"))
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

struct TransactionDetailModel: Decodable {
    var amount: Int
    var account: Int?
    var transactionDetailSplits: [TransactionDetailSplitModel]?
    
    enum CodingKeys: String, CodingKey {
        case amount
        case account
        case transactionDetailSplits = "transaction_detail_splits"
    }
}
