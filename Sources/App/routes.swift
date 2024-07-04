import Vapor
import Fluent

func routes(_ app: Application) throws {
    
    app.get("hello") { req async throws -> String in
        return "hello world!"
    }
    
    // MARK: - API routes
    let apis = app.grouped("api")
    
    try apis.register(collection: UserController())
    
    //MARK: Currencies
    apis.get("currencies") { req async throws -> [Currency] in
        return await currencies
    }
    
    //MARK: Users
    ///Create user
    ///`{ "name": String, "password": String }`
    apis.on(.POST, "users") { req async throws -> String in
        let user = try req.content.decode(User.self)
        let newDB = try await User.query(on: req.db).count() == 0
        user.admin = newDB
        
        if !newDB, try await User.query(on: req.db).filter(\.$name == user.name).first() != nil {
            throw MoneyErrors.duplicatedUser(user.name)
        }

        try await user.create(on: req.db)
        guard let userID = user.id else {
            throw MoneyErrors.failedCreateUser
        }
        return userID.description
    }
    
//    ///Get all users
//    apis.on(.GET, "user", ":id") { req async throws -> User in
//        guard let userID = req.parameters.get("id") else {
//            
//        }
//        
//        let user = try await User.query(on: req.db).
//        return users
//    }
    
    //MARK: Login
    apis.post("login") { req async throws -> String in
        let loginUser = try req.content.decode(User.self)
        guard let existUser = try await User.query(on: req.db).filter(\.$name == loginUser.name).first(),
              loginUser.password == existUser.password else {
            throw MoneyErrors.loginFailed
        }
        
        guard let userid = existUser.id else {
            throw MoneyErrors.fatalError("No id for user \(loginUser.name)")
        }
        
        return userid.description
    }
}
