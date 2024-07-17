//
//  AccountController.swift
//
//
//  Created by Shibo Tong on 14/7/2024.
//

import Vapor
import Fluent

///This controller contains all routes related to user, including create, update, delete users
struct AccountController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let accounts = routes.grouped("account")
        accounts.post(use: create)
        
        try accounts.grouped(UserAuthenticator()).group(":accountid") { account throws in
            account.put(use: update)
            account.delete(use: delete)
        }
    }

    ///Create book
    ///`{ "name": String, "currency": String }`
    ///`POST: /api/account`
    @Sendable func create(req: Request) async throws -> Account {
        guard let bookID: Int = req.parameters.get("bookid"),
              let accountName: String = req.content["name"],
              let currency: String = req.content["currency"],
              !accountName.isOnlySpacesOrEmpty else {
            throw Abort(.badRequest, reason: "Account name should not be empty")
        }
        
        let account = Account(name: accountName, currency: currency, bookid: bookID)

        try await account.create(on: req.db)
        
        return account
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

