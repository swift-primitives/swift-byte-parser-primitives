// Parser.Builder+Literal.swift
//
// Byte-specific `Parser.Builder` and `Parser.Take.Builder` `buildExpression`
// overloads enabling bare string literals and byte-array literals inside
// declarative parser bodies. Moved from swift-parser-primitives' `Parser Take
// Primitives` target in Wave 3 of the byte-extraction arc.

public import Parser_Primitives_Core
public import Parser_Take_Primitives

// MARK: - Parser.Builder String Literal Support

extension Parser.Builder
where Input: Parser.Input.Streaming, Input.Element == UInt8 {
    /// Enables bare string literals as `Parser.Literal` in `var body` builders.
    @inlinable
    public static func buildExpression(
        _ literal: Parser.Literal<Input>
    ) -> Parser.Literal<Input> {
        literal
    }

    /// Re-declared generic pass-through for constrained extension.
    @inlinable
    public static func buildExpression<P: Parser.`Protocol`>(
        _ parser: P
    ) -> P where P.Input == Input {
        parser
    }
}

// MARK: - Parser.Builder Byte Array Literal Support

extension Parser.Builder where Input == ArraySlice<UInt8> {
    /// Converts a `[UInt8]` array literal to a parser.
    @inlinable
    public static func buildExpression(_ bytes: [UInt8]) -> [UInt8] {
        bytes
    }
}

// MARK: - Parser.Take.Builder String Literal Support

extension Parser.Take.Builder
where Input: Parser.Input.Streaming, Input.Element == UInt8 {
    /// Enables bare string literals as `Parser.Literal` in builder bodies.
    ///
    /// ```swift
    /// Parser.Take.Sequence {
    ///     ASCII.Decimal.Parser<_, UInt16>()
    ///     ":"                                  // ← inferred as Parser.Literal<Input>
    ///     ASCII.Decimal.Parser<_, UInt16>()
    /// }
    /// ```
    @inlinable
    public static func buildExpression(
        _ literal: Parser.Literal<Input>
    ) -> Parser.Literal<Input> {
        literal
    }

    /// Re-declared generic pass-through for constrained extension.
    ///
    /// Without this, the `Parser.Literal` overload above shadows the
    /// generic `buildExpression` from the unconstrained extension,
    /// causing non-literal parsers to fail type-checking.
    @inlinable
    public static func buildExpression<P: Parser.`Protocol`>(
        _ parser: P
    ) -> P where P.Input == Input {
        parser
    }
}
