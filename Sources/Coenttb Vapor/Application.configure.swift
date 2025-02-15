//
//  Application.configure.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 25/08/2024.
//

import Foundation
import Vapor
import Logging

extension Application {
    public static func configure(
        app: Application,
        httpsRedirect: Bool?,
        canonicalHost: String?,
        allowedInsecureHosts: [String]?,
        baseUrl: URL,
        errorMiddleware: (Vapor.Environment) -> ErrorMiddleware = ErrorMiddleware.default(environment:)
    ) async throws {
        app.logger.info("Configuring application with environment: \(app.environment.name)")
        
        app.middleware.use { request, next in
            return try await withDependencies(from: request) {
                $0.request = request
            } operation: {
                try await next.respond(to: request)
            }
        }
        
        app.middleware.use(errorMiddleware(app.environment))
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
