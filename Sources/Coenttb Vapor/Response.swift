//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 30-12-2023.
//

import Foundation
import Vapor

extension Response {
    public static func success<T: Encodable>(
        _ success: Bool,
        data: T? = nil,
        message: String? = nil,
        status: HTTPStatus = .ok
    ) -> Response {
        return json(success: success, data: data, message: message, status: status)
    }
}

extension Response {
    public static func success(
        _ success: Bool,
        message: String? = nil,
        status: HTTPStatus = .ok
    ) -> Response {
        return json(success: success, data: EmptyResponse(), message: message, status: status)
    }
}

private struct EmptyResponse: Encodable {}

extension Response {
    public static func json<T: Encodable>(
        success: Bool,
        data: T? = nil,
        message: String? = nil,
        status: HTTPStatus = .ok
    ) -> Response {
        let response = APIResponse(success: success, data: data, message: message)
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
            let jsonData = try encoder.encode(response)
            
            return Response(
                status: status,
                headers: ["Content-Type": "application/json; charset=utf-8"],
                body: .init(data: jsonData)
            )
        } catch {
            return Response(status: .internalServerError, body: .init(string: "Failed to encode response"))
        }
    }
    
    public static func json(
        success: Bool,
        message: String? = nil,
        status: HTTPStatus = .ok
    ) -> Response {
        struct Empty: Codable {}
        return Self.json(success: success, data: Optional<Empty>.none, message: message, status: status)
    }
}

private struct APIResponse<T: Encodable>: Encodable {
    let success: Bool
    let data: T?
    let message: String?
    let timestamp: Date
    
    init(success: Bool, data: T?, message: String?) {
        self.success = success
        self.data = data
        self.message = message
        self.timestamp = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case success, data, message, timestamp
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encodeIfPresent(data, forKey: .data)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

extension Response {
    public static func robots(
        disallows: String
    ) -> Response {
        Response(
            status: .ok,
            body: .init(
                stringLiteral: """
                User-Agent: *
                \(disallows)
                """
            )
        )
    }
}

public extension Response {
    // 1xx
    static var `continue`: Response { .init(status: .`continue`) }
    static var switchingProtocols: Response { .init(status: .switchingProtocols) }
    static var processing: Response { .init(status: .processing) }
    // TODO: add '103: Early Hints' (requires bumping SemVer major).
    
    // 2xx
    static var ok: Response { .init(status: .ok) }
    static var created: Response { .init(status: .created) }
    static var accepted: Response { .init(status: .accepted) }
    static var nonAuthoritativeInformation: Response { .init(status: .nonAuthoritativeInformation) }
    static var noContent: Response { .init(status: .noContent) }
    static var resetContent: Response { .init(status: .resetContent) }
    static var partialContent: Response { .init(status: .partialContent) }
    static var multiStatus: Response { .init(status: .multiStatus) }
    static var alreadyReported: Response { .init(status: .alreadyReported) }
    static var imUsed: Response { .init(status: .imUsed) }
    
    // 3xx
    static var multipleChoices: Response { .init(status: .multipleChoices) }
    static var movedPermanently: Response { .init(status: .movedPermanently) }
    static var found: Response { .init(status: .found) }
    static var seeOther: Response { .init(status: .seeOther) }
    static var notModified: Response { .init(status: .notModified) }
    static var useProxy: Response { .init(status: .useProxy) }
    static var temporaryRedirect: Response { .init(status: .temporaryRedirect) }
    static var permanentRedirect: Response { .init(status: .permanentRedirect) }
    
    // 4xx
    static var badRequest: Response { .init(status: .badRequest) }
    static var unauthorized: Response { .init(status: .unauthorized) }
    static var paymentRequired: Response { .init(status: .paymentRequired) }
    static var forbidden: Response { .init(status: .forbidden) }
    static var notFound: Response { .init(status: .notFound) }
    static var methodNotAllowed: Response { .init(status: .methodNotAllowed) }
    static var notAcceptable: Response { .init(status: .notAcceptable) }
    static var proxyAuthenticationRequired: Response { .init(status: .proxyAuthenticationRequired) }
    static var requestTimeout: Response { .init(status: .requestTimeout) }
    static var conflict: Response { .init(status: .conflict) }
    static var gone: Response { .init(status: .gone) }
    static var lengthRequired: Response { .init(status: .lengthRequired) }
    static var preconditionFailed: Response { .init(status: .preconditionFailed) }
    static var payloadTooLarge: Response { .init(status: .payloadTooLarge) }
    static var uriTooLong: Response { .init(status: .uriTooLong) }
    static var unsupportedMediaType: Response { .init(status: .unsupportedMediaType) }
    static var rangeNotSatisfiable: Response { .init(status: .rangeNotSatisfiable) }
    static var expectationFailed: Response { .init(status: .expectationFailed) }
    static var imATeapot: Response { .init(status: .imATeapot) }
    static var misdirectedRequest: Response { .init(status: .misdirectedRequest) }
    static var unprocessableEntity: Response { .init(status: .unprocessableEntity) }
    static var locked: Response { .init(status: .locked) }
    static var failedDependency: Response { .init(status: .failedDependency) }
    static var upgradeRequired: Response { .init(status: .upgradeRequired) }
    static var preconditionRequired: Response { .init(status: .preconditionRequired) }
    static var tooManyRequests: Response { .init(status: .tooManyRequests) }
    static var requestHeaderFieldsTooLarge: Response { .init(status: .requestHeaderFieldsTooLarge) }
    static var unavailableForLegalReasons: Response { .init(status: .unavailableForLegalReasons) }
    
    // 5xx
    static var internalServerError: Response { .init(status: .internalServerError) }
    static var notImplemented: Response { .init(status: .notImplemented) }
    static var badGateway: Response { .init(status: .badGateway) }
    static var serviceUnavailable: Response { .init(status: .serviceUnavailable) }
    static var gatewayTimeout: Response { .init(status: .gatewayTimeout) }
    static var httpVersionNotSupported: Response { .init(status: .httpVersionNotSupported) }
    static var variantAlsoNegotiates: Response { .init(status: .variantAlsoNegotiates) }
    static var insufficientStorage: Response { .init(status: .insufficientStorage) }
    static var loopDetected: Response { .init(status: .loopDetected) }
    static var notExtended: Response { .init(status: .notExtended) }
    static var networkAuthenticationRequired: Response { .init(status: .networkAuthenticationRequired) }
}
