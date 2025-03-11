//
//  File.swift
//  coenttb-server-vapor
//
//  Created by Coen ten Thije Boonkkamp on 11/03/2025.
//

import Foundation
import Vapor

extension HTTPHeaders.Name {
    public static let xRateLimitLimit: Self = "X-RateLimit-Limit"
    public static let xRateLimitRemaining: Self = "X-RateLimit-Remaining"
    public static let xRateLimitReset: Self = "X-RateLimit-Reset"
    public static let xEmailRateLimitRemaining: Self = "X-Email-RateLimit-Remaining"
    public static let xIPRateLimitRemaining: Self = "X-IP-RateLimit-Remaining"
    public static let xRateLimitSource: Self = "X-RateLimit-Source"
    public static let xForwardedProto:Self = "X-Forwarded-Proto"
    public static let strictTransportSecurity:Self = "Strict-Transport-Security"
    public static let reauthorization: Self = "Reauthorization"
}
