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
        let currencies = await currencies
        var response: [[String: Any]] = []
        for currency in currencies {
            var result: [String: Any] = [:]
            result["name"] = currency.name
            result["code"] = currency.code
            result["demolinator"] = currency.demolinator
            response.append(result)
        }
        return try jsonResponse(response)
    }
}

func jsonResponse(_ dict: [Any]) throws -> String {
    let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    // here "jsonData" is the dictionary encoded in JSON data
    
    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
        throw MoneyError.jsonEncodeError
    }
    
    return jsonString
}
