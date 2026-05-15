// Byte.Parser.swift
//
// Single byte literal matching. The parser lives in the `Byte` domain per the
// institute's Domain.Subdomain naming convention: `Byte` is the byte-domain
// namespace; `Parser` is its parsing sub-role.
//
// Internally the parser works against `Input.Element == UInt8` streams; the
// API takes `Byte` at the surface so the type-domain story reads at the call
// site.

public import Byte_Primitives
public import Parser_Primitives_Core
public import Parser_EndOfInput_Primitives
public import Parser_Match_Primitives
public import Either_Primitives

extension Byte {
    /// A parser that matches a single byte.
    ///
    /// More efficient than `Byte.Literal.Parser` for single bytes. Requires
    /// only `Streaming` capability (no backtracking), making it suitable for
    /// forward-only input sources.
    ///
    /// The expected value is taken as `Byte` at the API boundary; the input
    /// is matched against `UInt8` because the input stream's `Element` is
    /// `UInt8`. The Byte type gives consumers a typed-domain anchor for the
    /// expected value at the call site.
    public struct Parser<Input: Input_Primitives.Input.Streaming>
    where Input.Element == UInt8 {
        @usableFromInline
        let expected: Byte

        @inlinable
        public init(_ expected: Byte) {
            self.expected = expected
        }
    }
}

extension Byte.Parser: Parser_Primitives_Core.Parser.`Protocol` {
    public typealias Output = Void
    public typealias Failure = Either<Parser_Primitives_Core.Parser.EndOfInput.Error, Parser_Primitives_Core.Parser.Match.Error>
    public typealias Body = Never

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) {
        guard !input.isEmpty else {
            throw .left(.unexpected(expected: "byte 0x\(String(expected.underlying, radix: 16, uppercase: true))"))
        }
        let actual = try! input.advance()
        guard actual == expected.underlying else {
            throw .right(.byteMismatch(expected: [expected.underlying], found: [actual]))
        }
    }
}

// MARK: - Printer Conformance

extension Byte.Parser: Parser_Primitives_Core.Parser.Printer
where Input: RangeReplaceableCollection {
    @inlinable
    public func print(_ output: Void, into input: inout Input) {
        input.insert(expected.underlying, at: input.startIndex)
    }
}
