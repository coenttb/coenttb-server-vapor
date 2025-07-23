//
//  RequestTimingMiddleware.swift
//  coenttb-server-vapor
//
//  Created by Coen ten Thije Boonkkamp on 23/07/2025.
//

import Foundation
import Vapor
import Dependencies

public struct RequestTimingMiddleware: AsyncMiddleware {
    public init() {}
    
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        @Dependency(\.continuousClock) var clock
        
        var result: Result<Response, Error>?
        
        let duration = await clock.measure {
            do {
                let response = try await next.respond(to: request)
                result = .success(response)
            } catch {
                result = .failure(error)
            }
        }
        
        let milliseconds = Int(duration.components.seconds * 1000 + duration.components.attoseconds / 1_000_000_000_000_000)
        
        switch result {
        case .success(let response):
            let message = [
                "\(response.status.code)",
                "\(milliseconds)ms",
                "\(request.method) \(request.url.string)",
                "request-id=\(request.id)"
            ]
                .joined(separator: " | ")
            
            request.logger.info("\(message)")
            return response
            
        case .failure(let error):
            request.logger.error(
                "\(request.method) \(request.url.string) -> ERROR [\(milliseconds)ms]: \(error)",
                metadata: ["request-id": .string(request.id)]
            )
            throw error
            
        case .none:
            request.logger.error("Request processing resulted in no outcome")
            throw Abort(.internalServerError)
        }
    }
}
