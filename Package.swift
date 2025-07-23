// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let coenttbFluent: Self = "Coenttb Fluent"
    static let coenttbVapor: Self = "Coenttb Vapor"
    static let coenttbVaporTesting: Self = "Coenttb Vapor Testing"
}

extension Target.Dependency {
    static var coenttbVapor: Self { .target(name: .coenttbVapor) }
    static var coenttbFluent: Self { .target(name: .coenttbFluent) }
    static var coenttbVaporTesting: Self { .target(name: .coenttbVaporTesting) }
}

extension Target.Dependency {
    static var coenttbServer: Self { .product(name: "Coenttb Server", package: "coenttb-server") }
    static var coenttbWeb: Self { .product(name: "Coenttb Web", package: "coenttb-web") }
    static var fluent: Self { .product(name: "Fluent", package: "fluent") }
    static var fluentPostgresDriver: Self { .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver") }
    static var rateLimiter: Self { .product(name: "RateLimiter", package: "coenttb-utils") }
    static var postgresKit: Self { .product(name: "PostgresKit", package: "postgres-kit") }
    static var vapor: Self { .product(name: "Vapor", package: "vapor") }
    static var vaporRouting: Self { .product(name: "VaporRouting", package: "vapor-routing") }
    static var vaporTesting: Self { .product(name: "VaporTesting", package: "vapor") }
}

let package = Package(
    name: "coenttb-server-vapor",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: .coenttbVapor, targets: [.coenttbVapor]),
        .library(name: .coenttbFluent, targets: [.coenttbFluent]),
        .library(name: .coenttbVaporTesting, targets: [.coenttbVaporTesting]),
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/coenttb-utils.git", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-server.git", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-web.git", branch: "main"),
        .package(url: "https://github.com/pointfreeco/vapor-routing.git", from: "0.1.3"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.7.2"),
        .package(url: "https://github.com/vapor/postgres-kit", from: "2.12.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.102.1"),
        
    ],
    targets: [
        .target(
            name: .coenttbFluent,
            dependencies: [
                .coenttbServer,
                .coenttbWeb,
                .fluent,
                .fluentPostgresDriver,
                .postgresKit,
                .rateLimiter,
                .coenttbVapor,
            ]
        ),
        .target(
            name: .coenttbVapor,
            dependencies: [
                .coenttbServer,
                .coenttbWeb,
                .vapor,
                .vaporRouting,
                .rateLimiter,
            ]
        ),
        .target(
            name: .coenttbVaporTesting,
            dependencies: [
                .coenttbVapor,
                .vaporTesting,
            ]
        ),
        
    ],
    swiftLanguageModes: [.v6]
)
