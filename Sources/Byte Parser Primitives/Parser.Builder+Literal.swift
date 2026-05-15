// Parser.Builder+Literal.swift
//
// Byte-specific `Parser.Builder` and `Parser.Take.Builder` `buildExpression`
// overloads enabling bare string literals and byte-array literals inside
// declarative parser bodies.
//
// String literals infer as `Byte.Literal.Parser` (the byte-domain parser
// for literal byte sequences); byte-array literals stay as `[UInt8]`. The
// overloads bridge SwiftPM Result Builder's spec-mirroring naming
// (`buildExpression` — exempt per [API-NAME-002] spec-mirroring) into the
// byte-domain types.

public import Byte_Primitives
public import Parser_Primitives_Core
public import Parser_Take_Primitives

// MARK: - Parser.Builder String Literal Support

extension Parser_Primitives_Core.Parser.Builder
where Input: Parser_Primitives_Core.Parser.Input.Streaming, Input.Element == UInt8 {
    /// Enables bare string literals as `Byte.Literal.Parser` in `var body`
    /// builders.
    @inlinable
    public static func buildExpression(
        _ literal: Byte.Literal.Parser<Input>
    ) -> Byte.Literal.Parser<Input> {
        literal
    }

    /// Re-declared generic pass-through for the constrained extension.
    @inlinable
    public static func buildExpression<P: Parser_Primitives_Core.Parser.`Protocol`>(
        _ parser: P
    ) -> P where P.Input == Input {
        parser
    }
}

// MARK: - Parser.Builder Byte Array Literal Support

extension Parser_Primitives_Core.Parser.Builder where Input == ArraySlice<UInt8> {
    /// Converts a `[UInt8]` array literal to a parser.
    @inlinable
    public static func buildExpression(_ bytes: [UInt8]) -> [UInt8] {
        bytes
    }
}

// MARK: - Parser.Take.Builder String Literal Support

extension Parser_Primitives_Core.Parser.Take.Builder
where Input: Parser_Primitives_Core.Parser.Input.Streaming, Input.Element == UInt8 {
    /// Enables bare string literals as `Byte.Literal.Parser` in builder bodies.
    ///
    /// ```swift
    /// Parser.Take.Sequence {
    ///     ASCII.Decimal.Parser<_, UInt16>()
    ///     ":"                              // ← inferred as Byte.Literal.Parser<Input>
    ///     ASCII.Decimal.Parser<_, UInt16>()
    /// }
    /// ```
    @inlinable
    public static func buildExpression(
        _ literal: Byte.Literal.Parser<Input>
    ) -> Byte.Literal.Parser<Input> {
        literal
    }

    /// Re-declared generic pass-through for the constrained extension.
    ///
    /// Without this, the `Byte.Literal.Parser` overload above would shadow
    /// the generic `buildExpression` from the unconstrained extension,
    /// causing non-literal parsers to fail type-checking.
    @inlinable
    public static func buildExpression<P: Parser_Primitives_Core.Parser.`Protocol`>(
        _ parser: P
    ) -> P where P.Input == Input {
        parser
    }
}
