//
//  Application.configure.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 25/08/2024.
//

import Foundation
import Vapor
import Logging
import Coenttb_Web_EnvVars

extension Application {
    public static func configure(
        application: Application,
        httpsRedirect: Bool?,
        canonicalHost: String?,
        allowedInsecureHosts: [String]?,
        baseUrl: URL
    ) async throws {
        @Dependency(\.envVars) var envVars
        
        application.environment = .init(envVarsEnvironment: envVars.appEnv)
        
        application.logger.info("Configuring application with environment: \(application.environment.name)")
        
        application.middleware.use { request, next in
            return try await withDependencies {
                $0.request = request
            } operation: {
                try await next.respond(to: request)
            }
        }
        
        application.middleware.use(HTTPSRedirectMiddleware(on: httpsRedirect == true))
        
        if let canonicalHost = canonicalHost {
            application.middleware.use(
                CanonicalHostMiddleware(
                    canonicalHost: canonicalHost,
                    allowedInsecureHosts: allowedInsecureHosts ?? [],
                    baseUrl: baseUrl,
                    logger: application.logger
                )
            )
        }
        
        application.middleware.use(FileMiddleware(publicDirectory: application.directory.publicDirectory))
    }
}
