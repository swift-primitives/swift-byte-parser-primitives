// Parser.Byte.swift
//
// Single byte literal matching, parameterized by the Byte type at the API
// surface. Internally the parser still works against `Input.Element == UInt8`
// streams; the API takes `Byte_Primitives.Byte` so the type-domain story
// reads at the call site.

public import Byte_Primitives
public import Parser_Primitives_Core
public import Parser_EndOfInput_Primitives
public import Parser_Match_Primitives
public import Either_Primitives

extension Parser {
    /// A parser that matches a single byte.
    ///
    /// More efficient than `Literal` for single bytes.
    ///
    /// This parser only requires `Streaming` capability (no backtracking),
    /// making it suitable for forward-only input sources.
    ///
    /// The expected value is taken as `Byte_Primitives.Byte` at the API
    /// boundary; the input is matched as `UInt8` because the input stream's
    /// `Element` is `UInt8`. The Byte type gives consumers a typed domain
    /// for the expected value at the call site.
    public struct Byte<Input: Parser.Input.Streaming>
    where Input.Element == UInt8 {
        @usableFromInline
        let expected: Byte_Primitives.Byte

        @inlinable
        public init(_ expected: Byte_Primitives.Byte) {
            self.expected = expected
        }
    }
}

extension Parser.Byte: Parser.`Protocol` {
    public typealias Output = Void
    public typealias Failure = Either<Parser.EndOfInput.Error, Parser.Match.Error>

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

extension Parser.Byte: Parser.Printer
where Input: RangeReplaceableCollection {
    @inlinable
    public func print(_ output: Void, into input: inout Input) {
        input.insert(expected.underlying, at: input.startIndex)
    }
}
