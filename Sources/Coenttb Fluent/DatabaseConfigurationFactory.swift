//
//  File.swift
//  coenttb-server-vapor
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import Foundation
import Coenttb_Server
import PostgresKit
import Fluent

extension DatabaseConfigurationFactory {
    public static var postgres: Self {
        @Dependency(\.sqlConfiguration) var sqlConfiguration
        @Dependency(\.databaseConfiguration) var databaseConfiguration
        
        return .postgres(
            configuration: sqlConfiguration,
            maxConnectionsPerEventLoop: databaseConfiguration.maxConnectionsPerEventLoop,
            connectionPoolTimeout: databaseConfiguration.connectionPoolTimeout
        )
    }
}
