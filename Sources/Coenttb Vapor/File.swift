//
//  File.swift
//  coenttb-server-vapor
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import Foundation
import Coenttb_Fluent
import Dependencies

extension DatabaseKey {
    public static let liveValue: (any Fluent.Database) = {
        @Dependency(\.request?.db) var request
        @Dependency(\.application.db) var application
        
        return request ?? application
        
    }()
}
