//
//  RouteCollection+Extension.swift
//  
//
//  Created by Shibo Tong on 5/7/2024.
//

import Foundation
import Vapor

extension RouteCollection {
    func jsonString(_ dictionary: [String: Any]) throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw Abort(.internalServerError, reason: "Not a json value")
        }
        return jsonString
    }
}
