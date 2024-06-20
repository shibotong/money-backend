import Vapor
import Fluent

func routes(_ app: Application) throws {
    
    // MARK: - API routes
    let apis = app.grouped("api")
    
    //MARK: Currencies
    apis.get("currencies") { req async throws -> [Currency] in
        return await currencies
    }
    
    //MARK: Users
    ///Create user
    ///`{ "name": String, "password": String }`
    apis.on(.POST, "user") { req async throws -> String in
        let user = try req.content.decode(User.self)
        
        var checkAdmin = user.admin ?? false
        let existUsers = try await User.query(on: req.db).all()
        
        for existUser in existUsers {
            if existUser.name == user.name {
                throw MoneyErrors.duplicatedUser(user.name)
            }
            
            if checkAdmin, existUser.admin == true {
                throw MoneyErrors.multipleAdminUser
            }
        }

        try await user.create(on: req.db)
        guard let userID = user.id else {
            throw MoneyErrors.failedCreateUser
        }
        return userID.description
    }
    
    ///Get all users
    apis.on(.GET, "user") { req async throws -> [User] in
        let users = try await User.query(on: req.db).all()
        return users
    }
    
    //MARK: Login
    apis.post("login") { req async throws -> LoginUser in
        let loginUser = try req.content.decode(User.self)
        guard let existUser = try await User.query(on: req.db).filter(\.$name == loginUser.name).first(),
              loginUser.password == existUser.password else {
            throw MoneyErrors.loginFailed
        }
        
        return LoginUser(from: existUser)
    }
}
