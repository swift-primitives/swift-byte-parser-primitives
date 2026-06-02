//
//  String+Collection.Byte.swift
//  swift-byte-parser-primitives
//
//  UTF-8 decoding bridge from an institute byte collection to Swift.String.
//
//  Companion to swift-byte-primitives' `String+Byte` (which bridges any
//  `Swift.Sequence` of byte-domain elements). This overload accepts the institute
//  `Collection.`Protocol`` — which is NOT a `Swift.Sequence` — so byte-stream
//  parsers can decode a `Collection.Slice.`Protocol`` slice for diagnostics
//  without conforming their input to `& Swift.Collection`. Materializes via index
//  traversal (the `ASCII.Decimal.Float.Slow` idiom), then forwards to stdlib UTF-8
//  decoding.
//

public import Byte_Primitives
public import Collection_Primitives

extension Swift.String {
    /// Creates a string by decoding an institute byte collection as UTF-8.
    ///
    /// Mirrors `String.init(decoding:as:)`, lifted to the institute
    /// `Collection.`Protocol`` over any `Byte.`Protocol`` element. Invalid byte
    /// sequences are replaced with U+FFFD per stdlib semantics.
    ///
    /// - Parameters:
    ///   - bytes: an institute byte collection (e.g. a parser's input slice).
    ///   - encoding: the UTF-8 codec.
    ///
    /// `@_disfavoredOverload` so that a type conforming to BOTH this institute
    /// `Collection.`Protocol`` and `Swift.Sequence` (e.g. the concrete `Byte.Input`)
    /// resolves to swift-byte-primitives' `Swift.Sequence` overload — identical
    /// result — leaving this overload as the sole candidate only for institute-only
    /// collections (a generic `Collection.Slice.`Protocol``-bound parser input).
    @_disfavoredOverload
    @inlinable
    public init<C: Collection.`Protocol`>(
        decoding bytes: borrowing C,
        as encoding: Swift.UTF8.Type
    ) where C.Element: Byte.`Protocol` {
        var raw: [UInt8] = []
        var index = bytes.startIndex
        while index < bytes.endIndex {
            raw.append(bytes[index].byte.underlying)
            bytes.formIndex(after: &index)
        }
        self.init(decoding: raw, as: encoding)
    }
}
