//
//  Abort.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 09/10/2024.
//

import Foundation
import Vapor

extension Abort {
    public static let requestUnavailable: Self = Abort(.internalServerError, reason: "Request is unavailable")
}
