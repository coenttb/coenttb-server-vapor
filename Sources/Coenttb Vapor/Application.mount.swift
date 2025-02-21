//
//  Application.mount.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 02-01-2024.
//

import Foundation
import URLRouting
import Vapor

extension Application {
    public func mount<R: Parser & Sendable>(
        _ router: R,
        use closure: @Sendable @escaping (Request, Vapor.AsyncResponder, R.Output) async throws -> Vapor.Response
    ) where R.Input == URLRequestData {
        self.middleware.use(AsyncRoutingMiddleware(router: router, respond: closure))
    }
}

private struct AsyncRoutingMiddleware<Router: Parser & Sendable>: AsyncMiddleware
where Router.Input == URLRequestData {
    let router: Router
    let respond: @Sendable (Request, AsyncResponder, Router.Output) async throws -> Vapor.Response
    
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Response {
        
        if request.body.data == nil {
            try await _ = request.body.collect(max: request.application.routes.defaultMaxBodySize.value)
                .get()
        }
        
        guard let requestData = URLRequestData(request: request)
        else { return try await next.respond(to: request) }
        
        let route: Router.Output
        do {
            route = try self.router.parse(requestData)
        } catch let routingError {
            do {
                return try await next.respond(to: request)
            } catch {
                request.logger.info("\(routingError)")
                
                guard request.application.environment == .development
                else { throw error }
                
                return Response(status: .notFound, body: .init(string: "Routing \(routingError)"))
            }
        }
        return try await self.respond(request, next, route).encodeResponse(for: request)
    }
}

extension Application {
    /// Mounts a router to the Vapor application. Assumed usage of Application.configure that sets the Request to Dependencies.
    ///
    /// - Parameters:
    ///   - router: A parser-printer that works on inputs of `URLRequestData`.
    ///   - closure: A closure that takes the router's output as an argument.
    public func mount<R: Parser>(
        _ router: R,
        use closure: @escaping (R.Output) async throws -> any AsyncResponseEncodable
    ) where R.Input == URLRequestData {
        @Dependency(\.request!) var request
        self.mount(router, use: { req, output in
            return try await closure(output)
        })
    }
}



