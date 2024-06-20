//
//  Errors.swift
//
//
//  Created by Shibo Tong on 20/6/2024.
//

import Foundation
import Vapor

class MoneyErrors {
    static let multipleAdminUser = Abort(.forbidden, reason: "Only one admin user is allowed")
    static let failedCreateUser = Abort(.internalServerError, reason: "An unexpected error occurred while creating the user.")
    static func duplicatedUser(_ name: String) -> Abort {
        Abort(.conflict, reason: "Username '\(name)' is already taken.")
    }
}
