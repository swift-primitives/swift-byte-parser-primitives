// Byte.Literal.Parser.swift
//
// Literal byte sequence matching. The parser lives in the `Byte.Literal`
// sub-domain per the institute's Domain.Subdomain naming convention: `Byte`
// is the byte-domain namespace; `Literal` is the byte-literal sub-concept;
// `Parser` is its parsing role.

internal import Array_Primitives
public import Byte_Primitives
public import Either_Primitives
public import Parser_EndOfInput_Primitives
public import Parser_Match_Primitives
public import Parser_Primitives

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
    public struct Parser<Input: Input_Primitives.Input.Streaming>
    where Input.Element == Byte {
        @usableFromInline
        let bytes: [Byte]

        /// Creates a parser that matches the given byte sequence.
        @inlinable
        public init(_ bytes: [Byte]) {
            self.bytes = bytes
        }

        /// Creates a parser that matches the UTF-8 bytes of the given string.
        @inlinable
        public init(_ string: StaticString) {
            unsafe (self.bytes = string.utf8Start.withMemoryRebound(
                to: UInt8.self,
                capacity: string.utf8CodeUnitCount
            ) { ptr in
                let buf = unsafe UnsafeBufferPointer(start: ptr, count: string.utf8CodeUnitCount)
                var typed: [Byte] = []
                typed.reserveCapacity(buf.count)
                // swift-format-ignore
                // Tool quirk: swift-format's auto-fix merges `unsafe byte` into
                // `unsafebyte` here (verified via scratch --in-place trial) — a
                // compile-breaking corruption of the SE-0458 `unsafe` pattern-binding
                // keyword. Left as hand-verified-correct; not applying the suggested edit.
                for unsafe byte in unsafe buf { typed.append(Byte(byte)) }
                return typed
            })
        }
    }
}

extension Byte.Literal.Parser: Parser_Primitives.Parser.`Protocol` {
    /// The parser produces no value on success.
    public typealias Output = Void
    /// The parser's failure: end-of-input, or a byte mismatch.
    public typealias Failure = Either<Parser_Primitives.Parser.EndOfInput.Error, Parser_Primitives.Parser.Match.Error>
    /// This is a primitive parser; it has no derived body.
    public typealias Body = Never

    /// Matches the byte sequence, consuming it from the input.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) {
        for expected in bytes {
            guard !input.isEmpty else {
                throw .left(.unexpected(expected: "byte 0x\(String(expected.underlying, radix: 16, uppercase: true))"))
            }
            // swift-format-ignore: NeverUseForceTry
            // Safe: `isEmpty` was just checked above — `advance()` only throws `.empty`.
            // swiftlint:disable:next force_try
            let actual = try! input.advance()
            guard actual == expected else {
                throw .right(.byteMismatch(expected: [expected.underlying], found: [actual.underlying]))
            }
        }
    }
}

extension Byte.Literal.Parser: ExpressibleByStringLiteral {
    /// Creates a parser from a string literal's UTF-8 bytes.
    @inlinable
    public init(stringLiteral value: String) {
        var typed: [Byte] = []
        for byte in value.utf8 { typed.append(Byte(byte)) }
        self.bytes = typed
    }
}

extension Byte.Literal.Parser: ExpressibleByUnicodeScalarLiteral {
    /// Creates a parser from a single Unicode scalar's UTF-8 bytes.
    @inlinable
    public init(unicodeScalarLiteral value: Unicode.Scalar) {
        var typed: [Byte] = []
        for byte in String(value).utf8 { typed.append(Byte(byte)) }
        self.bytes = typed
    }
}

extension Byte.Literal.Parser: ExpressibleByExtendedGraphemeClusterLiteral {
    /// Creates a parser from a single character's UTF-8 bytes.
    @inlinable
    public init(extendedGraphemeClusterLiteral value: Character) {
        var typed: [Byte] = []
        for byte in String(value).utf8 { typed.append(Byte(byte)) }
        self.bytes = typed
    }
}

// MARK: - Printer Conformance

extension Byte.Literal.Parser: Parser_Primitives.Parser.Printer
where Input: RangeReplaceableCollection {
    /// Writes the matched byte sequence back into the input.
    @inlinable
    public func print(_ output: Void, into input: inout Input) {
        input.insert(contentsOf: bytes, at: input.startIndex)
    }
}
