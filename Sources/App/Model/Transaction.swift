//
//  Transaction.swift
//  
//
//  Created by Shibo Tong on 14/7/2024.
//

import Foundation
import Vapor
import Fluent
import SQLKit

final class Transaction: Model, Content, @unchecked Sendable {
    
    static let schema = "transaction"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Parent(key: "book_id")
    var book: Book
    
    @Children(for: \.$transaction)
    var transactionDetails: [TransactionDetail]
    
    @Field(key: "latitude")
    var latitude: Float?
    
    @Field(key: "longitude")
    var longitude: Float?
    
    @Field(key: "description")
    var description: String?
    
    @Field(key: "type")
    var type: String
    
    @Field(key: "transaction_date")
    var date: Date
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(id: Int? = nil,
         bookid: Int,
         latitude: Float? = nil,
         longitude: Float? = nil,
         description: String? = nil,
         type: TransactionType,
         date: Date) {
        self.id = id
        self.$book.id = bookid
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.type = type.rawValue
        self.date = date
    }
}

enum TransactionType: String {
    case income, expense, transfer
}

extension Transaction: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Self.schema)
            .field("id", .int, .identifier(auto: true))
            .field("book_id", .int, .required, .references("book", "id"))
            .field("latitude", .float)
            .field("longitude", .float)
            .field("description", .string)
            .field("type", .string, .required)
            .field("transaction_date", .datetime, .required)
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

struct TransactionModel: Decodable {
    var latitude: Float?
    var longitude: Float?
    var description: String?
    var type: String
    var date: Date
    var transactionDetails: [TransactionDetailModel]
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case description
        case type
        case date
        case transactionDetails = "transaction_details"
    }
}
