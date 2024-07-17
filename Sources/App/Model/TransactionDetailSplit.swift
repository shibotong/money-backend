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

final class TransactionDetailSplit: Model, Content, @unchecked Sendable {
    
    static let schema = "transaction_detail_split"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "category_id")
    var categoryID: Int
    
    @Field(key: "amount")
    var amount: Int
    
    @Parent(key: "transaction_detail_id")
    var transactionDetail: TransactionDetail
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(id: Int? = nil,
         categoryID: Int,
         amount: Int,
         transactionDetailID: Int) {
        self.id = id
        self.amount = amount
        self.categoryID = categoryID
        self.$transactionDetail.id = transactionDetailID
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
            .field("updated_at", .datetime, .required, .sql(.default(SQLFunction("now"))))
            .field("deleted_at", .datetime)
            .ignoreExisting()
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Self.schema).delete()
    }
}

struct TransactionDetailSplitModel: Decodable {
    var categoryID: Int
    var amount: Int
    
    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case amount
    }
}
