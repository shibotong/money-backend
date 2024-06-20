//
//  CurrencyController.swift
//
//
//  Created by Shibo Tong on 20/6/2024.
//

import Foundation
import Vapor

@MainActor
let currencies: [Currency] = [
    USD(),
    AUD(),
    CNY()
]

protocol Currency: Sendable {
    var name: String { get }
    var code: String { get }
    var demolinator: Int { get }
}

struct USD: Currency {
    var name = "United States Dollar"
    var code = "USD"
    var demolinator = 100
}

struct AUD: Currency {
    var name = "Australian Dollar"
    var code = "USD"
    var demolinator = 100
}

struct CNY: Currency {
    var name = "Chinese Yuan"
    var code = "CNY"
    var demolinator = 100
}


