// Byte.Literal.Parser.swift
//
// Literal byte sequence matching. The parser lives in the `Byte.Literal`
// sub-domain per the institute's Domain.Subdomain naming convention: `Byte`
// is the byte-domain namespace; `Literal` is the byte-literal sub-concept;
// `Parser` is its parsing role.

public import Byte_Primitives
public import Parser_Primitives_Core
public import Parser_EndOfInput_Primitives
public import Parser_Match_Primitives
public import Either_Primitives
internal import Array_Primitives_Core

extension Byte {
    /// Namespace for byte-literal types — fixed byte sequences interpreted
    /// as literal patterns to match or emit.
    public enum Literal {}
}

extension Byte.Literal {
    /// A parser that matches a specific byte sequence.
    ///
    /// `Parser` consumes exact bytes from the input, succeeding with `Void`
    /// output. Ideal for delimiters, magic numbers, and keyword matching.
    ///
    /// Requires only `Streaming` capability (no backtracking). Note that on
    /// partial-match failure, input is left partially consumed.
    public struct Parser<Input: Parser_Primitives_Core.Parser.Input.Streaming>
    where Input.Element == UInt8 {
        @usableFromInline
        let bytes: [UInt8]

        @inlinable
        public init(_ bytes: [UInt8]) {
            self.bytes = bytes
        }

        @inlinable
        public init(_ string: StaticString) {
            unsafe (self.bytes = Swift.Array(
                string.utf8Start.withMemoryRebound(to: UInt8.self, capacity: string.utf8CodeUnitCount) {
                    UnsafeBufferPointer(start: $0, count: string.utf8CodeUnitCount)
                }
            ))
        }
    }
}

extension Byte.Literal.Parser: Parser_Primitives_Core.Parser.`Protocol` {
    public typealias Output = Void
    public typealias Failure = Either<Parser_Primitives_Core.Parser.EndOfInput.Error, Parser_Primitives_Core.Parser.Match.Error>
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) {
        for expected in bytes {
            guard !input.isEmpty else {
                throw .left(.unexpected(expected: "byte 0x\(String(expected, radix: 16, uppercase: true))"))
            }
            let actual = try! input.advance()
            guard actual == expected else {
                throw .right(.byteMismatch(expected: [expected], found: [actual]))
            }
        }
    }
}

extension Byte.Literal.Parser: ExpressibleByStringLiteral {
    @inlinable
    public init(stringLiteral value: String) {
        self.bytes = Swift.Array(value.utf8)
    }
}

extension Byte.Literal.Parser: ExpressibleByUnicodeScalarLiteral {
    @inlinable
    public init(unicodeScalarLiteral value: Unicode.Scalar) {
        self.bytes = Swift.Array(String(value).utf8)
    }
}

extension Byte.Literal.Parser: ExpressibleByExtendedGraphemeClusterLiteral {
    @inlinable
    public init(extendedGraphemeClusterLiteral value: Character) {
        self.bytes = Swift.Array(String(value).utf8)
    }
}

// MARK: - Printer Conformance

extension Byte.Literal.Parser: Parser_Primitives_Core.Parser.Printer
where Input: RangeReplaceableCollection {
    @inlinable
    public func print(_ output: Void, into input: inout Input) {
        input.insert(contentsOf: bytes, at: input.startIndex)
    }
}
