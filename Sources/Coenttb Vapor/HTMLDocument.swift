//
//  HTMLDocument.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 27/05/2022.
//

import CoenttbHTML
import Vapor

extension HTMLDocument {
    public func encodeResponse(for request: Request) async throws -> Vapor.Response {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/html")
        let bytes: ContiguousArray<UInt8> = self.render()
        let string: String = String(decoding: bytes, as: UTF8.self)
        return .init(status: .ok, headers: headers, body: .init(string: string))
    }
}

// Cannot extend protocol with inheritence clause. The conforming type should declare AsyncResponseEncodable.
// extension HTMLDocument: AsyncResponseEncodable {}
