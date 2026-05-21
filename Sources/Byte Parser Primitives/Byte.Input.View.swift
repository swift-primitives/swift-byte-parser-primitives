public import Byte_Primitives
public import Cursor_Primitives_Core

extension Byte.Input {
    /// Borrowed input view for zero-copy bytes parsing.
    ///
    /// `Byte.Input.View` is a typealias for the institute's unified
    /// single-generic borrowed-bytes cursor — ``Cursor`` parameterized over
    /// ``Byte``. Storage derives from `Byte.Borrowed` via Byte's
    /// `Ownership.Borrow.`Protocol`` conformance; position is typed
    /// `Tagged<Byte, Ordinal>` (≡ `Index<Byte>`) per the typed-position
    /// discipline.
    ///
    /// ## Lifetime
    ///
    /// `~Copyable` and `~Escapable` — the cursor cannot be duplicated and
    /// cannot outlive the span it borrows. Compiler-enforced via
    /// `@_lifetime(borrow source)` on the underlying primitive's initializer.
    ///
    /// ## NOT Sendable
    ///
    /// Borrowed views must not cross task boundaries. For cross-task transfer
    /// use ``Byte/Input`` (Copyable, `[UInt8]`-backed).
    ///
    /// ## Provenance
    ///
    /// Relocated from `swift-binary-parser-primitives` 2026-05-18 per the
    /// `binary-bytes-input-removal` arc (successor to the
    /// `typed-input-unification` arc). The byte-domain owned-input identity
    /// (`Byte.Input`) is the canonical home; this typealias formerly lived
    /// under an older binary-byte sub-namespace shape with the same
    /// underlying instantiation.
    public typealias View = Cursor<Byte>
}

// MARK: - Byte-domain public API
//
// The trivial-alias wrappers (`isEmpty`, `first`, `consumedCount`,
// `removeFirst()`, `removeFirst(_:Int)`, `subscript(offset:Int)`) were
// removed 2026-05-21 per the byte-input-view-primitives arc Pass 2.
// Consumers now call Cursor's native API directly:
//   • `view.isAtEnd`                         (was `view.isEmpty`)
//   • `view.peek()`                          (was `view.first`)
//   • `Int(bitPattern: view.position)`       (was `view.consumedCount`)
//   • `view.consume()`                       (was `view.removeFirst()`)
//   • `view.advance(by: Tagged<Byte, Cardinal>)` (was `view.removeFirst(_:Int)`)
//   • `view.peek(at: typedCount)`            (was `view[offset: Int]`)
// The byte-domain typed-Index subscript (`view[offset: Index<Byte>]`) is
// retained in `Byte.Input.View+typed.swift`; it encapsulates the Ordinal
// → Cardinal conversion at the API boundary.

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
    /// Use this when you need to store or send the input across concurrency domains.
    ///
    /// - Returns: An owned `Byte.Input` containing the remaining bytes.
    @inlinable
    public func copyToOwned() -> Byte.Input {
        let remaining = Int(bitPattern: count)
        var bytes: [Byte] = []
        bytes.reserveCapacity(remaining)
        var i: Int = 0
        while i < remaining {
            let typedOffset = Tagged<Byte, Cardinal>(_unchecked: Cardinal(UInt(bitPattern: i)))
            if let b = peek(at: typedOffset) {
                bytes.append(b)
            }
            i += 1
        }
        return Byte.Input(bytes.map(\.underlying))
    }
}
