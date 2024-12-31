//
//  Vapor.Environment.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2024.
//

import Foundation
import Vapor

extension Vapor.Environment {
    public static let staging: Self = .custom(name: "staging")
}
