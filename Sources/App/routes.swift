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
    
    //MARK: Currencies
    apis.get("currencies") { req async throws -> [Currency] in
        return await currencies
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
