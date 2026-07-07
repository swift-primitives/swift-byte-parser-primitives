// Parseable+Byte.Input.swift
//
// Byte-domain convenience for `Parseable`. Moved from
// swift-parser-primitives' `Parseable.swift` in the byte-extraction arc's
// Phase-B cleanup — the original lived in parser-primitives because it
// referenced the now-deleted `Parser.Input.Bytes` typealias. Byte.Input
// is the canonical replacement; this extension belongs in
// byte-parser-primitives (the new home for byte-domain parser concerns).

public import Byte_Primitives
public import Parser_Primitives

// MARK: - Byte Input Convenience

extension Parseable
where
    Parser.Input == Byte.Input,
    Parser.Output == Self
{
    /// Creates a value by parsing ASCII bytes using the canonical parser.
    ///
    /// - Parameter ascii: The ASCII bytes to parse.
    /// - Throws: `Parser.Failure` if parsing fails.
    @inlinable
    public init(ascii: [UInt8]) throws(Parser.Failure) {
        var input = Byte.Input(ascii)
        self = try Self.parser.parse(&input)
    }
}
