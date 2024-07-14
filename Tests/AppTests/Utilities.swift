//
//  File.swift
//  
//
//  Created by Shibo Tong on 5/7/2024.
//

@testable import App
import Foundation
import XCTVapor
import FluentPostgresDriver

extension String {
    /// Generates a random string with given length
    ///
    /// - Source: [StackOverflow](https://stackoverflow.com/a/26845710)
    /// - License: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
    static func random(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
      return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    var dictionaryValue: [String: Any] {
        if let jsonData = self.data(using: .utf8) {
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    return dictionary
                } else {
                    return [:]
                }
            } catch {
                return [:]
            }
        } else {
            return [:]
        }
    }
}

extension XCTestCase {
    
    var fakeUserID: String {
        "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
    }
    
    func setupDatabase(dbName: String, username: String, password: String) async throws-> Application {
        let app = try await Application.make(.testing)
        try await configure(app)
        
        let postgres = app.db(.psql) as! PostgresDatabase
        
        _ = try await postgres.simpleQuery("CREATE USER \(username) WITH PASSWORD '\(password)'").get()
        _ = try await postgres.simpleQuery("CREATE DATABASE \(dbName)").get()
        _ = try await postgres.simpleQuery("ALTER DATABASE \(dbName) OWNER TO \(username)").get()
        
        let configuration = SQLPostgresConfiguration(hostname: "localhost",
                                                     port: SQLPostgresConfiguration.ianaPortNumber,
                                                     username: username,
                                                     password: password,
                                                     database: dbName,
                                                     tls: .disable)
        let databaseId = DatabaseID(string: dbName)
        
        app.databases.use(
            .postgres(configuration: configuration),
            as: databaseId
        )
        app.databases.default(to: databaseId)
        try await app.autoMigrate()
        return app
    }
    
    func removeDatabase(dbName: String, username: String) async throws {
        let clearDatabaseApp = try await Application.make(.testing)
        try await configure(clearDatabaseApp)
        let postgres = clearDatabaseApp.db(.psql) as! PostgresDatabase
        _ = try await postgres.simpleQuery("DROP DATABASE \(dbName)").get()
        _ = try await postgres.simpleQuery("DROP USER IF EXISTS \(username)").get()
        try await clearDatabaseApp.asyncShutdown()
    }
    
    func authorization(token: String) -> HTTPHeaders {
        HTTPHeaders([("Authorization", "Bearer \(token)")])
    }
}
