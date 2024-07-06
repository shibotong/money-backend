//
//  Category.swift
//
//
//  Created by Shibo Tong on 5/7/2024.
//

import Foundation
import Vapor
import Fluent

final class Category: Model, Content {
    
    static let schema = "category"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "category_name")
    var name: String
    
    @Field(key: "user_id")
    var userid: UUID
    
    init() {}
    
    init(id: UUID? = nil, name: String, userid: UUID) {
        self.id = id
        self.name = name
        self.userid = userid
    }
}
