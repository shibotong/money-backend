//
//  BackendClient.swift
//  
//
//  Created by Shibo Tong on 14/6/2024.
//

import Foundation
import PostgresNIO

class BackendClient {
    
    static let shared = BackendClient()
    
    let client: PostgresClient
    
    init() {
        let config = PostgresClient.Configuration(
            host: "localhost",
            port: 5432,
            username: "my",
            password: "",
            database: "mydb",
            tls: .disable
        )
        
        client = PostgresClient(configuration: config)
    }
    
    func startClient() async {
        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask { [weak self] in
                await self?.client.run()
            }
            
            taskGroup.cancelAll()
        }
    }
}
