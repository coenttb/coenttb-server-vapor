//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 19/12/2024.
//


import Coenttb_Server_Utils
import Dependencies
import Foundation
import Vapor

extension Vapor.Request: @retroactive DependencyKey {
    public static let testValue: Vapor.Request? = nil
    public static let liveValue: Vapor.Request? = nil
}

extension DependencyValues {
    public var request: Vapor.Request? {
        get { self[Vapor.Request.self] }
        set { self[Vapor.Request.self] = newValue }
    }
}

public struct RequestError: Error {
    let int: Int

    public init(_ int: Int) {
        self.int = int
    }
}

extension Request {
    /// Attempts to extract geolocation information from request headers
    public var geoLocation: GeoLocation? {
        // Cloudflare headers
        let country = headers.first(name: "CF-IPCountry")
        let region = headers.first(name: "CF-Region")
        let city = headers.first(name: "CF-City")
        
        // If any geolocation data is present, return it
        if country != nil || region != nil || city != nil {
            return GeoLocation(
                country: country,
                region: region,
                city: city
            )
        }
        
        return nil
    }
}

extension Request {
    /// Gets the real IP address considering various headers
    public var realIP: String {
        // Try Cloudflare header first
        if let cfConnectingIP = headers.first(name: "CF-Connecting-IP") {
            return cfConnectingIP
        }
        
        // Then try X-Real-IP
        if let xRealIP = headers.first(name: "X-Real-IP") {
            return xRealIP
        }
        
        // Then try X-Forwarded-For (first IP in the list)
        if let forwardedFor = headers.first(name: "X-Forwarded-For")?.split(separator: ",").first {
            return String(forwardedFor).trimmingCharacters(in: .whitespaces)
        }
        
        // Fall back to the direct remote address
        return remoteAddress?.hostname ?? "unknown"
    }
}

extension Request {
    public struct GeoLocation: Sendable, Hashable {
        public let country: String?
        public let region: String?
        public let city: String?
    }
}
