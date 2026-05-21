public import Cardinal_Primitives
public import Index_Primitives
public import Byte_Primitives
public import Cursor_Primitives_Core

// MARK: - Typed Subscript

extension Cursor where DomainTag == Byte {
    /// Accesses the byte at the given typed index offset from the current position.
    ///
    /// Encapsulates the `Index<Byte>` (Ordinal) → `Tagged<Byte, Cardinal>`
    /// conversion at the API boundary, delegating to Cursor's native
    /// `peek(at: Tagged<DomainTag, Cardinal>)` for the actual lookup.
    /// Returns `Byte` directly (not Optional) — traps on out-of-bounds.
    ///
    /// - Parameter index: The typed offset from the current position.
    /// - Precondition: `index` must be within bounds.
    /// - Returns: The byte at the given offset.
    @inlinable
    @_lifetime(copy self)
    public subscript(offset index: Index<Byte>) -> Byte {
        guard let byte = peek(at: index.map { Cardinal($0) }) else {
            preconditionFailure("subscript offset out of bounds")
        }
        return byte
    }
}
