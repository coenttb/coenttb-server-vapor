//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 20/09/2024.
//

import Foundation
import Fluent

extension SchemaBuilder {
    @discardableResult
    public func field(
        _ keys: [FieldKey],
        _ dataType: DatabaseSchema.DataType,
        _ constraints: DatabaseSchema.FieldConstraint...
    ) -> Self {
        self.field(.definition(
            name: .key(.init(stringLiteral: keys.map(\.description).joined(separator: "_"))),
            dataType: dataType,
            constraints: constraints
        ))
    }
}
