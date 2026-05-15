// Byte.Input.swift
//
// `Byte.Input` is the canonical byte-stream input type for byte-domain
// parsers — `Byte.Parser`, `Byte.Literal.Parser`, and any future
// byte-domain parser combinators. Per LargerDomain.Subdomain, Byte is the
// data domain and Input is the cursor-role within it.
//
// The typealias lives in `swift-byte-parser-primitives`, NOT in
// `swift-byte-primitives`. byte-primitives stays a pure value layer
// (struct + Byte.Protocol + bitwise + stdlib conformances) with no
// input/parser dep; consumers that only need the byte value type pull
// byte-primitives without dragging input infrastructure.
//
// Input and Parser are PEERS — neither is a sub-domain of the other.
// They compose via type parameters: `Byte.Parser<Input>` is generic
// over any `Parser.Input.Streaming` conformer. `Byte.Input` is the
// canonical concrete choice for byte-array streams.

public import Byte_Primitives
public import Input_Primitives
public import Array_Dynamic_Primitives

extension Byte {
    /// The canonical byte-stream input for byte-domain parsers.
    ///
    /// Built on `Input.Slice<Array<UInt8>.Indexed<UInt8>>` — a zero-copy
    /// view over the institute's indexed byte array. Conforms to
    /// `Input.Streaming` (and the stronger `Input.Protocol` for
    /// backtracking-capable parsers) because `Array<UInt8>.Indexed<UInt8>`
    /// is `Collection.\`Protocol\``-conforming and `Copyable`.
    ///
    /// ```swift
    /// var input = Byte.Input([0x48, 0x65, 0x6C])
    /// try Byte.Parser<Byte.Input>(0x48).parse(&input)
    /// // input now cursors past 0x48 to 0x65
    /// ```
    public typealias Input = Input_Primitives.Input.Slice<Array<UInt8>.Indexed<UInt8>>
}

// MARK: - Convenience initializers on Byte.Input

extension Input_Primitives.Input.Slice where Base == Array<UInt8>.Indexed<UInt8> {
    /// Creates a byte-stream input from a stdlib `[UInt8]`.
    @inlinable
    public init(_ bytes: Swift.Array<UInt8>) {
        var storage = Array<UInt8>()
        for byte in bytes {
            storage.append(byte)
        }
        self = Input.Slice(Array<UInt8>.Indexed<UInt8>(storage))
    }

    /// Creates a byte-stream input from a string's UTF-8 representation.
    @inlinable
    public init(utf8 string: Swift.String) {
        self.init(Swift.Array<UInt8>(string.utf8))
    }
}
