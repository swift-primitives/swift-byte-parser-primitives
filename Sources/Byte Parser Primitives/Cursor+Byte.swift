public import Byte_Primitives
public import Cursor_Primitives
public import Memory_Cursor_Primitives
// W3 PRUNE: Cursor<Byte>.storage is now Swift.Span<Byte>; cursor operations
// dispatch on `Swift.Span: Span.`Protocol`` — import the conformance
// directly for the inlinable call sites (Finding 3/8).
public import Span_Protocol_Primitives

// MARK: - Cursor<Byte> — byte-domain extensions
//
// `Cursor<Byte>` is the institute's borrowed-bytes cursor — `Cursor`
// parameterized over `Byte`. The Cursor-native API (`position`, `count`,
// `isAtEnd`, `peek`, `peek(at:)`, `advance`, `advance(by:)`, `consume`,
// `seek(to:)`) lives in `swift-cursor-primitives` and is generic over
// `DomainTag`. This file adds the genuinely byte-specific surface:
//
//   • `starts(with:)` — typed-prefix match against any `Byte`-shaped sequence
//   • `copyToOwned() -> Byte.Input` — borrowed → owned conversion

extension Cursor where DomainTag == Byte {
    /// Checks if the remaining bytes start with the given prefix.
    ///
    /// - Parameter prefix: The prefix to check.
    /// - Returns: `true` if the remaining bytes start with the prefix.
    @inlinable
    public func starts(with prefix: some Swift.Sequence<some Byte.`Protocol`>) -> Bool {
        var offset: Tagged<Byte, Cardinal> = .zero
        for byte in prefix {
            guard let observed = peek(at: offset), observed == byte.byte else { return false }
            offset += .one
        }
        return true
    }
}

// MARK: - Domain owned-form conversion

extension Cursor where DomainTag == Byte {
    /// Copies the remaining bytes to an owned input.
    ///
    /// Use this when you need to store or send the input across concurrency
    /// domains.
    ///
    /// - Returns: An owned `Byte.Input` containing the remaining bytes.
    @inlinable
    public func copyToOwned() -> Byte.Input {
        var bytes: [Byte] = []
        bytes.reserveCapacity(count)
        var offset: Tagged<Byte, Cardinal> = .zero
        while offset < count {
            guard let byte = peek(at: offset) else { break }
            bytes.append(byte)
            offset += .one
        }
        return Byte.Input(bytes.map(\.underlying))
    }
}
