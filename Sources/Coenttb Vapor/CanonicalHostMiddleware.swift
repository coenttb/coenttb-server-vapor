//
//  CanonicalHostMiddleware.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 15/12/2024.
//

import Foundation
import Vapor
import Dependencies

public struct CanonicalHostMiddleware: AsyncMiddleware {
    private let canonicalHost: String
    private let allowedInsecureHosts: [String]
    private let baseUrl: URL
    private let logger: Logger

    public init(canonicalHost: String, allowedInsecureHosts: [String], baseUrl: URL, logger: Logger) {
        self.canonicalHost = canonicalHost
        self.allowedInsecureHosts = allowedInsecureHosts
        self.baseUrl = baseUrl
        self.logger = logger
    }

    public func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder) async throws -> Vapor.Response {
        
        guard let currentHostWithPort = request.headers.first(name: .host) else {
            throw Abort(.forbidden, reason: "Missing host header")
        }

        // Split the host and port for validation
        let currentHost = currentHostWithPort.split(separator: ":").first.map(String.init) ?? currentHostWithPort

        // Create a list of allowed hosts
        let allowedHosts = Set(allowedInsecureHosts + [
            canonicalHost,
            baseUrl.host
        ].compactMap { $0 })

        // Check if the current host is allowed
        guard allowedHosts.contains(currentHost) else {
            logger.warning("Request from unauthorized host: \(currentHost)")
            throw Abort(.forbidden, reason: "Host not allowed")
        }
        
        if currentHostWithPort != canonicalHost {
            if
                let requestURL = URL(string: request.url.string),
                let canonicalURL = URL.canonical(url: requestURL, canonicalHost: canonicalHost) {
                return request.redirect(to: canonicalURL.absoluteString, redirectType: .permanent)
            } else {
                logger.error("Failed to create canonical URL from: \(request.url.string)")
            }
        }

        return try await next.respond(to: request)
    }
}
