import Vapor
import Fluent

func routes(_ app: Application) throws {
    
    app.get("hello") { req async throws -> String in
        return "hello world!"
    }
    
    // MARK: - API routes
    let apis = app.grouped("api")
    
    // register users endpoint
    try apis.register(collection: UserController())
    try apis.register(collection: CategoryController())
    
    //MARK: Currencies
    apis.get("currencies") { req async throws -> [Currency] in
        return await currencies
    }
    
    //MARK: Login
    ///Login
    ///`{ "username": String, "password": String }`
    apis.post("login") { req async throws -> String in
        guard let username: String = req.content["username"],
              let password: String = req.content["password"],
              let existUser = try await User.query(on: req.db).filter(\.$username == username).first(),
              password == existUser.password,
              let userid = existUser.id?.uuidString else {
            throw Abort(.unauthorized, reason: "Invalid username or password")
        }
        
        return userid
    }
}
