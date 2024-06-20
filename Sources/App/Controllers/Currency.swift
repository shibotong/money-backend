//
//  Currency.swift
//
//
//  Created by Shibo Tong on 20/6/2024.
//

import Foundation

@MainActor
let currencies: [Currency] = [
    Currency(code: "USD", denominator: 100, name: "United States Dollar"),
    Currency(code: "AUD", denominator: 100, name: "Australian Dollar"),
    Currency(code: "CNY", denominator: 100, name: "Chinese Yuan")
]

struct Currency: Sendable, Codable {
    let code: String
    let denominator: Int
    let name: String
}


