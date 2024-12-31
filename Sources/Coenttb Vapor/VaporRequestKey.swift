//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 04-01-2024.
//

import Dependencies
import Foundation
import Vapor

extension DependencyValues {
    public var request: Vapor.Request? {
        get { self[VaporRequestKey.self] }
        set { self[VaporRequestKey.self] = newValue }
    }
}

public enum VaporRequestKey: TestDependencyKey {
    public static let testValue: Vapor.Request? = nil
}

extension VaporRequestKey: DependencyKey {
    public static let liveValue: Vapor.Request? = nil
}

public struct RequestError: Error {
    let int: Int

    public init(_ int: Int) {
        self.int = int
    }
}
