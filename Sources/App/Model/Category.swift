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
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "userid")
    var userid: UUID?
    
    @Children(for: \.$category)
    var subCategories: [SubCategory]
    
    init() {}
    
    init(id: Int? = nil, name: String, userid: UUID? = nil) {
        self.id = id
        self.name = name
        self.userid = userid
    }
}
