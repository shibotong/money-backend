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
}
