// Byte.Parser.swift
//
// Single byte literal matching. The parser lives in the `Byte` domain per the
// institute's Domain.Subdomain naming convention: `Byte` is the byte-domain
// namespace; `Parser` is its parsing sub-role.
//
// The parser works against `Input.Element == Byte` streams — byte-domain
// throughout. The error payload converts Byte → UInt8 at the boundary
// because `Parser.Match.Error.byteMismatch` is UInt8-typed (stdlib-shape
// across all parser packages).

public import Byte_Primitives
public import Either_Primitives
public import Parser_EndOfInput_Primitives
public import Parser_Match_Primitives
public import Parser_Primitives

extension Byte {
    /// A parser that matches a single byte.
    ///
    /// More efficient than `Byte.Literal.Parser` for single bytes. Requires
    /// only `Streaming` capability (no backtracking), making it suitable for
    /// forward-only input sources.
    ///
    /// The expected value and the input's `Element` are both `Byte`. The
    /// error payload converts to UInt8 at the boundary.
    public struct Parser<Input: Input_Primitives.Input.Streaming>
    where Input.Element == Byte {
        @usableFromInline
        let expected: Byte

        /// Creates a parser that matches the given byte.
        @inlinable
        public init(_ expected: Byte) {
            self.expected = expected
        }
    }
}

extension Byte.Parser: Parser_Primitives.Parser.`Protocol` {
    /// The parser produces no value on success.
    public typealias Output = Void
    /// The parser's failure: end-of-input, or a byte mismatch.
    public typealias Failure = Either<Parser_Primitives.Parser.EndOfInput.Error, Parser_Primitives.Parser.Match.Error>
    /// This is a primitive parser; it has no derived body.
    public typealias Body = Never

    /// Matches a single byte, consuming it from the input.
    @inlinable
    public func parse(_ input: inout Input) throws(Failure) {
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

// MARK: - Printer Conformance

extension Byte.Parser: Parser_Primitives.Parser.Printer
where Input: RangeReplaceableCollection {
    /// Writes the matched byte back into the input.
    @inlinable
    public func print(_ output: Void, into input: inout Input) {
        input.insert(expected, at: input.startIndex)
    }
}
