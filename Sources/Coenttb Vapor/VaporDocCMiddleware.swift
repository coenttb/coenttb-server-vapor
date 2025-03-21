//
//  VaporDocCMiddleware.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2024.
//

import Foundation
import Vapor

public struct VaporDocCMiddleware: AsyncMiddleware {
    public let archivePath: URL
    public let redirectRoot: String?
    public let redirectMissingTrailingSlash: Bool
    private let prefix: String = "/"
    
    public init(archivePath: URL, redirectRoot: String? = nil, redirectMissingTrailingSlash: Bool = false) {
        self.archivePath = archivePath
        self.redirectRoot = redirectRoot
        self.redirectMissingTrailingSlash = redirectMissingTrailingSlash
    }
    
    public func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder) async throws -> Vapor.Response {
        guard var path = request.url.path.removingPercentEncoding
        else { throw Abort(.badRequest) }
        
        guard !path.contains("../")
        else { throw Abort(.forbidden) }
        
        guard path.hasPrefix(self.prefix)
        else { throw Abort(.forbidden) }
        
        if path == self.prefix, let redirectRoot = redirectRoot {
             return request.redirect(to: redirectRoot)
        }
        
        path = String(path.dropFirst(self.prefix.count))
        
        let indexPrefixes = [
            "documentation",
            "tutorials",
        ]
        
        for indexPrefix in indexPrefixes where path.hasPrefix(indexPrefix) {
            if indexPrefixes.contains(path) {
                if redirectMissingTrailingSlash {
                    return request.redirect(to: self.prefix + path + "/")
                } else {
                    return try await next.respond(to: request)
                }
            }
            
            return try await serveStaticFileRelativeToArchive("index.html", request: request)
        }
        
        if path == "data/documentation.json" {
            if FileManager.default.fileExists(atPath: archivePath.appendingPathComponent("data/documentation.json", isDirectory: true).path) {
                return try await serveStaticFileRelativeToArchive("data/documentation.json", request: request)
            }
            
            request.logger.info("\(self.prefix)data/documentation.json was not found, attempting to find product's JSON in /data/documentation/ directory")
            
            let documentationPath = archivePath.appendingPathComponent("data/documentation", isDirectory: true)
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: documentationPath.path)
                guard let productJSON = contents.first(where: { $0.hasSuffix(".json") }) else {
                    return try await next.respond(to: request)
                }
                
                return try await serveStaticFileRelativeToArchive("data/documentation/\(productJSON)", request: request)
            } catch {
                return try await next.respond(to: request)
            }
        }
        
        let staticFiles = [
            "favicon.ico",
            "favicon.svg",
            "theme-settings.json",
            "index/index.json"
        ]
        
        for staticFile in staticFiles where path == staticFile {
            return try await serveStaticFileRelativeToArchive(staticFile, request: request)
        }
        
        let staticFilePrefixes = [
            "css/",
            "js/",
            "data/",
            "images/",
            "downloads/",
            "img/",
            "videos/",
            "index/"
        ]
        
        for staticFilePrefix in staticFilePrefixes where path.hasPrefix(staticFilePrefix) {
            return try await serveStaticFileRelativeToArchive(path, request: request)
        }
        
        return try await next.respond(to: request)
    }
    
    private func serveStaticFileRelativeToArchive(_ staticFilePath: String, request: Request) async throws -> Response {
        let staticFilePath = archivePath.appendingPathComponent(staticFilePath, isDirectory: false)
        return try await request
            .fileio
            .asyncStreamFile(
                at: staticFilePath.path
            )
    }
}



//import Foundation
//import Vapor
//
///// Vapor middleware that serves files from a DocC archive.
//public struct VaporDocCMiddleware: AsyncMiddleware {
//     
//    
//    /// The path to the DocC archive.
//    public let archivePath: URL
//
//    /// The path to redirect a request to the root (`/`) to. When `nil`
//    /// no redirection will occur.
//    public let redirectRoot: String?
//
//    /// When `true` the `/documentation` and `/tutorials` endpoints will
//    /// be redirected to `/documentation/` and `/tutorials/` respectively.
//    public let redirectMissingTrailingSlash: Bool
//
//    /// The website prefix. If DocC supports being hosted outside
//    /// of the root directory this property will become public.
//    private let prefix: String = "/"
//
//    /// Create a new middleware that serves files from the DocC archive at ``archivePath``.
//    ///
//    /// When the ``redirectMissingTrailingSlash`` parameter is `true` the `/documentation` and `/tutorials`
//    /// endpoints will be redirected to `/documentation/` and `/tutorials/` respectively.
//    ///
//    /// - Parameter archivePath: The path to the DocC archive.
//    /// - Parameter redirectRoot: When non-nil the root (`/`) will be redirected to the provided path. Defaults to `nil.`
//    /// - Parameter redirectMissingTrailingSlash: When `true` paths the require trailing slashes will be redirected to include the trailing slash. Defaults to `false`.
//    public init(archivePath: URL, redirectRoot: String? = nil, redirectMissingTrailingSlash: Bool = false) {
//        self.archivePath = archivePath
//        self.redirectRoot = redirectRoot
//        self.redirectMissingTrailingSlash = redirectMissingTrailingSlash
//    }
//
//    public func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder) async throws -> Vapor.Response {
//        guard var path = request.url.path.removingPercentEncoding else {
//            throw Abort(.badRequest)
//        }
//
//        guard !path.contains("../") else {
//            throw Abort(.forbidden)
//        }
//
//        guard path.hasPrefix(self.prefix) else {
//            throw Abort(.forbidden)
//        }
//
//        if path == self.prefix, let redirectRoot = redirectRoot {
//            return request.redirect(to: redirectRoot)
//        }
//
//        path = String(path.dropFirst(self.prefix.count))
//
//        let indexPrefixes = [
//            "documentation",
//            "tutorials",
//        ]
//
//        for indexPrefix in indexPrefixes where path.hasPrefix(indexPrefix) {
//            if indexPrefixes.contains(path) {
//                // No trailing slash on request
//                if redirectMissingTrailingSlash {
//                    return request.redirect(to: self.prefix + path + "/")
//                } else {
//                    return try await next.respond(to: request)
//                }
//            }
//
//            return try await serveStaticFileRelativeToArchive("index.html", request: request)
//        }
//
//        if path == "data/documentation.json" {
//            if FileManager.default.fileExists(atPath: archivePath.appendingPathComponent("data/documentation.json", isDirectory: true).path) {
//                return try await serveStaticFileRelativeToArchive("data/documentation.json", request: request)
//            }
//
//            request.logger.info("\(self.prefix)data/documentation.json was not found, attempting to find product's JSON in /data/documentation/ directory")
//
//            // The docs generated by Xcode 13.0 beta 1 request "/data/documentation.json" but the
//            // generated archive puts this file under "/data/documentation/{product_name}.json".
//            // Feedback logged under FB9156617.
//            let documentationPath = archivePath.appendingPathComponent("data/documentation", isDirectory: true)
//            do {
//                let contents = try FileManager.default.contentsOfDirectory(atPath: documentationPath.path)
//                guard let productJSON = contents.first(where: { $0.hasSuffix(".json") }) else {
//                    return try await next.respond(to: request)
//                }
//
//                return try await serveStaticFileRelativeToArchive("data/documentation/\(productJSON)", request: request)
//            } catch {
//                return try await next.respond(to: request)
//            }
//        }
//
//        let staticFiles = [
//            "favicon.ico",
//            "favicon.svg",
//            "theme-settings.json",
//            "index/index.json"
//        ]
//
//        for staticFile in staticFiles where path == staticFile {
//            return try await serveStaticFileRelativeToArchive(staticFile, request: request)
//        }
//
//        let staticFilePrefixes = [
//            "css/",
//            "js/",
//            "data/",
//            "images/",
//            "downloads/",
//            "img/",
//            "videos/",
//            "index/"
//        ]
//
//        for staticFilePrefix in staticFilePrefixes where path.hasPrefix(staticFilePrefix) {
//            return try await serveStaticFileRelativeToArchive(path, request: request)
//        }
//
//        return try await next.respond(to: request)
//    }
//
//    private func serveStaticFileRelativeToArchive(_ staticFilePath: String, request: Request) async throws -> Response {
//        let staticFilePath = archivePath.appendingPathComponent(staticFilePath, isDirectory: false)
//        return request.fileio.streamFile(at: staticFilePath.path)
//    }
//}
