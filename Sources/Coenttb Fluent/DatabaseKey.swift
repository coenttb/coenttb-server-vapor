//
//  File.swift
//  coenttb-server-vapor
//
//  Created by Coen ten Thije Boonkkamp on 17/02/2025.
//

import Foundation
import Dependencies
import Fluent
import IssueReporting
import Coenttb_Vapor

public enum DatabaseKey {}

extension DatabaseKey: TestDependencyKey {
    public static let testValue: (any Fluent.Database) = liveValue
}

extension DatabaseKey: DependencyKey {
    public static let liveValue: (any Fluent.Database) = {
        @Dependency(\.request?.db) var request
        @Dependency(\.application.db) var application
        
        return request ?? application
        
    }()
}

extension DependencyValues {
    public var database: (any Fluent.Database) {
        get { self[DatabaseKey.self] }
        set { self[DatabaseKey.self] = newValue }
    }
}



