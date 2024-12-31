//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 31/08/2024.
//

import Foundation



/// example usage: connectToPostgres(databaseUrl: "...", username: "...", password: "...", authenticate: database.authenticate)
///
@discardableResult
public func connectToPostgres<Authenticated>(
    databaseUrl: URL,
    username: String,
    password: String,
    authenticate: (_ username: String, _ password: String) async throws -> Authenticated
) async -> Authenticated {
    while true {
        print("  ⚠️ Connecting to PostgreSQL at \(databaseUrl)")
        do {
            let x = try await authenticate(username, password)
            print("  ✅ Connected to PostgreSQL!")
            return x
        } catch {
            print("  ❌ Error! \(error)")
            print("     Make sure you are running postgres")
            try? await Task.sleep(for: .seconds(1))
        }
    }
}
