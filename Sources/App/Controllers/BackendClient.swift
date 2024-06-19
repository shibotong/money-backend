//
//  BackendClient.swift
//
//
//  Created by Shibo Tong on 14/6/2024.
//

import Foundation
import PostgresNIO

final class BackendClient: Sendable {
    
    static let shared = BackendClient()
    
    let client: PostgresClient
    
    init() {
        // createdb mydb -p 3001 -U abcd -W abcd
        let config = PostgresClient.Configuration(
            host: "localhost",
            port: 5432,
            username: "money_app",
            password: "money_app",
            database: "money-app",
            tls: .disable
        )
        
        client = PostgresClient(configuration: config)
        
        Task {
            await client.run()
        }
    }
    
    func queryUser() async -> String {
        do {
            let rows = try await client.query("SELECT rolname FROM pg_roles")
            var result = ""
            for try await row in rows {
                // do something with the row
                result += row.description
            }
            return result
        } catch {
            return error.localizedDescription
        }
    }
    
    func queryUserTables() async -> String {
        do {
            let rows = try await client.query("SELECT user_name, password FROM moneyuser")
            var result = ""
            for try await row in rows {
                // do something with the row
                result += row.description
            }
            return result
        } catch {
            return error.localizedDescription
        }
    }
    
    func createUser(name: String, password: String) async throws -> String {
        let queryString = "INSERT INTO MONEYUSER (user_name, password) VALUES ('\(name)', '\(password)')"
        print(queryString)
        let query = PostgresQuery(stringLiteral: queryString)
        try await client.query(query)
        return "Insert user success"
    }
}
