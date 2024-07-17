//
//  TransactionController.swift
//
//
//  Created by Shibo Tong on 17/7/2024.
//

import Vapor
import Fluent

/// Routes controller for adding, updating, deleting transactions
struct TransactionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let transactions = routes.grouped("transaction")
        transactions.post(use: create)
        
        try transactions.group(":transactionid") { transaction throws in
            transaction.put(use: update)
            transaction.delete(use: delete)
        }
    }

    ///Create transaction
    ///```{
    ///     "latitude": Float,
    ///     "longitude": Float,
    ///     "description": String,
    ///     "type": String,
    ///     "date": Date,
    ///     "transactionDetails" [
    ///         {
    ///            "amount": Int,
    ///            "account": Int,
    ///            "transaction_detail_splits": [
    ///             "category": Int,
    ///             "amount": Int
    ///            ]
    ///          }
    ///     ]
    ///   }
    ///
    ///`POST: /api/account`
    @Sendable func create(req: Request) async throws -> String {
        guard let bookID: Int = req.parameters.get("bookid") else {
            throw Abort(.badRequest, reason: "Account name should not be empty")
        }
//        guard let type: String = req.content["type"],
//              let date: Date = req.content["date"] else {
//            throw Abort(.badRequest, reason: "type and date should not be empty")
//        }
        
        let transaction = try req.content.decode(TransactionModel.self)
        print(transaction)
        
        return "abc"
    }
    
    ///Update account name
    ///`{ "name": String, "currency": String }`
    @Sendable func update(req: Request) async throws -> Account {
        guard let account = try await Account.find(req.parameters.get("accountid"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        if let accountName: String = req.content["name"] {
            guard !accountName.isOnlySpacesOrEmpty else {
                throw Abort(.badRequest, reason: "Account name should not be empty")
            }
            account.accountName = accountName
        }
        
        if let currency: String = req.content["currency"] {
            account.currency = currency
        }

        try await account.save(on: req.db)
        return account
    }
    
//    @Sendable func show(req: Request) async throws -> String {
//        guard let userid = req.parameters.get("id"),
//              let uuid = UUID(uuidString: userid) else {
//            throw Abort(.badRequest, reason: "Id is required for this operation")
//        }
//
//        let user = try await findUser(id: uuid, req: req)
//
//        var result: [String: Any] = ["username": user.username, "admin": user.admin]
//        if let deletedAt = user.deletedAt {
//            result["deletedAt"] = deletedAt
//        }
//        return try jsonString(result)
//    }

    ///Delete a book based on userid
    @Sendable func delete(req: Request) async throws -> HTTPStatus {
        guard let account = try await Account.find(req.parameters.get("accountid"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await account.delete(on: req.db)
        return .ok
    }
}

