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

final class Transaction: Model, Content {
    
    static let schema = "transaction"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "bookid")
    var bookid: Int?
    
    @Field(key: "latitude")
    var latitude: Float?
    
    @Field(key: "longitude")
    var longitude: Float?
    
    @Field(key: "description")
    var description: String?
    
    @Field(key: "type")
    var type: String
    
    @Timestamp(key: "created_at", on: .create)
    var createAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(id: Int? = nil,
         bookid: Int? = nil,
         latitude: Float? = nil,
         longitude: Float? = nil,
         description: String? = nil,
         type: TransactionType) {
        self.id = id
        self.bookid = bookid
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.type = type.rawValue
    }
}

enum TransactionType: String {
    case income, expense, transfer
}

extension Transaction: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Self.schema)
            .field("id", .int, .identifier(auto: true))
            .field("bookid", .int, .required, .references("book", "id"))
            .field("latitude", .float)
            .field("longitude", .float)
            .field("description", .string)
            .field("type", .string, .required)
            .field("created_at", .datetime, .required, .sql(.default(SQLFunction("now"))))
            .field("deleted_at", .datetime)
            .ignoreExisting()
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Self.schema).delete()
    }
}
