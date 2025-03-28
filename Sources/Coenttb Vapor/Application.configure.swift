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
        app: Application,
        httpsRedirect: Bool?,
        canonicalHost: String?,
        allowedInsecureHosts: [String]?,
        baseUrl: URL
    ) async throws {
        @Dependency(\.envVars) var envVars
        
        app.environment = .init(envVarsEnvironment: envVars.appEnv)
        
        app.logger.info("Configuring application with environment: \(app.environment.name)")
        
        app.middleware.use { request, next in
            return try await withDependencies {
                $0.request = request
            } operation: {
                try await next.respond(to: request)
            }
        }
        
        app.middleware.use(HTTPSRedirectMiddleware(on: httpsRedirect == true))
        
        if let canonicalHost = canonicalHost {
            app.middleware.use(
                CanonicalHostMiddleware(
                    canonicalHost: canonicalHost,
                    allowedInsecureHosts: allowedInsecureHosts ?? [],
                    baseUrl: baseUrl,
                    logger: app.logger
                )
            )
        }
        
        app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    }
}
