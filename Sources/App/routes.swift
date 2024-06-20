import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }
    
    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    app.get("postgresql") { req async -> String in
        return await BackendClient.shared.queryUser()
    }
    
    app.get("users") { req async -> String in
        return await BackendClient.shared.queryUserTables()
    }
    
    app.get("create") { req async -> String in
        do {
            let result = try await BackendClient.shared.createUser(name: "testuser", password: "testpass")
            return result
        } catch {
            return error.localizedDescription
        }
    }
    
    // MARK: - API routes
    let apis = app.grouped("api")
    
    ///Get all currencies
    apis.get("currencies") { req async throws -> String in
        return try jsonResponse(await currencies)
    }
}

func jsonResponse(_ dict: Codable) throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    let jsonData = try encoder.encode(dict)
    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
        throw MoneyError.jsonEncodeError
    }
    
    return jsonString
}
