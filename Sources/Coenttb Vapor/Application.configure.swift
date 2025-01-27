//
//  Application.configure.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 25/08/2024.
//

import Foundation
import Vapor
import Logging
import Coenttb_Server_EnvVars

extension Application {
    public static func configure(
        app: Application,
        httpsRedirect: Bool?,
        canonicalHost: String?,
        allowedInsecureHosts: [String]?,
        baseUrl: URL
    ) async throws {
        app.logger.info("Configuring application with environment: \(app.environment.name)")
        app.middleware.use(ErrorMiddleware.default(environment: app.environment))
        app.middleware.use(HTTPSRedirectMiddleware(on: httpsRedirect == true))
        
        @Dependency(\.envVars.port) var port
        app.http.server.configuration.port = port
        
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
