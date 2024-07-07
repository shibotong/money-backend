//
//  SubCategory.swift
//  
//
//  Created by Shibo Tong on 7/7/2024.
//

import Foundation
import Vapor
import Fluent

final class SubCategory: Model, Content {
    
    static let schema = "subcategory"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "name")
    var name: String
    
    @Parent(key: "categoryid")
    var category: Category
    
    init() {}
    
    init(id: Int? = nil, name: String, categoryID: Category.IDValue) {
        self.id = id
        self.name = name
        self.$category.id = categoryID
    }
}
