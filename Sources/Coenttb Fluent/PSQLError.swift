//
//  File.swift
//  coenttb-server-vapor
//
//  Created by Coen ten Thije Boonkkamp on 13/02/2025.
//

import Foundation
import PostgresNIO

extension PSQLError {
    public var isTableNotFoundError: Bool {
        code == .server && serverInfo?[.sqlState] == "42P01"
    }
}
