//
//  Vapor.Environment.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2024.
//

import Foundation
import Vapor
import EnvironmentVariables

extension Vapor.Environment {
    public static let staging: Self = .custom(name: "staging")
}

extension Vapor.Environment {
    public init(envVarsEnvironment: EnvVars.AppEnv) {
        self = switch envVarsEnvironment {
        case .development: .development
        case .production: .production
        case .staging: .staging
        case .testing: .testing
        }
    }
}
