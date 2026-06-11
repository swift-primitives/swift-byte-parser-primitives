// Byte.Input.swift
//
// `Byte.Input` is the canonical byte-stream input type for byte-domain
// parsers — `Byte.Parser`, `Byte.Literal.Parser`, and any future
// byte-domain parser combinators. Per LargerDomain.Subdomain, Byte is the
// data domain and Input is the cursor-role within it.
//
// The typealias lives in `swift-byte-parser-primitives`, NOT in
// `swift-byte-primitives`. byte-primitives stays a pure value layer
// (struct + Byte.Protocol + bitwise + stdlib conformances) with no
// input/parser dep; consumers that only need the byte value type pull
// byte-primitives without dragging input infrastructure.
//
// Input and Parser are PEERS — neither is a sub-domain of the other.
// They compose via type parameters: `Byte.Parser<Input>` is generic
// over any `Input_Primitives.Input.Streaming` conformer. `Byte.Input` is the
// canonical concrete choice for byte-array streams.

public import Byte_Primitives
public import Input_Primitives
public import Array_Primitives
public import Column_Primitives
// The column vocabulary is pure typealiases (zero re-exports): conformances of
// the expanded column spelling resolve against the modules that DECLARE them,
// and MemberImportVisibility requires those modules imported by this file —
// Shared's store/buffer seam + Span.Protocol conformances (Shared_Primitive),
// the heap buffer's (Buffer_Linear_Primitive), the contiguous storage's
// (Storage_Contiguous_Primitives), and Memory.Heap: Region
// (Memory_Heap_Primitives).
public import Shared_Primitive
public import Buffer_Linear_Primitive
public import Buffer_Linear_Primitives
public import Storage_Contiguous_Primitives
public import Memory_Heap_Primitives

extension Byte {
    /// The canonical byte-stream input for byte-domain parsers.
    ///
    /// Built on `Input.Slice<Array<Column.Shared<Byte>>>` — a zero-copy view
    /// over a byte array on the `Shared` (CoW value-semantic) column. Conforms
    /// to `Input_Primitives.Input.Streaming` (and the stronger `Input.Protocol`
    /// for backtracking-capable parsers) because `Array<Column.Shared<Byte>>`
    /// is `Collection.\`Protocol\``-conforming (the column vends a span, so the
    /// span-bridged Collection lattice chains through) and `Copyable` (the CoW
    /// column over a `Copyable` element — `Input.Slice` requires a `Copyable`
    /// `Base`, and parser backtracking copies inputs, so value semantics are
    /// load-bearing here).
    ///
    /// ```swift
    /// var input = Byte.Input([0x48, 0x65, 0x6C])
    /// try Byte.Parser<Byte.Input>(0x48).parse(&input)
    /// // input now cursors past 0x48 to 0x65
    /// ```
    public typealias Input = Input_Primitives.Input.Slice<Array<Column.Shared<Byte>>>
}

// MARK: - Convenience initializers on Byte.Input

extension Input_Primitives.Input.Slice where Base == Array<Column.Shared<Byte>> {
    /// Creates a byte-stream input from `[Byte]`.
    @inlinable
    public init(_ bytes: Swift.Array<Byte>) {
        var storage = Array<Column.Shared<Byte>>()
        for byte in bytes {
            storage.append(byte)
        }
        self = Input.Slice(storage)
    }

    /// Creates an input cursor from any byte collection.
    ///
    /// - Parameter bytes: The bytes to parse.
    @inlinable
    public init<Bytes: Swift.Collection>(_ bytes: Bytes) where Bytes.Element == Byte {
        self.init(Swift.Array(bytes))
    }

    /// Creates a byte-stream input from a stdlib `[UInt8]`.
    ///
    /// Stdlib-interop forwarder per [API-BYTE-006] — carries
    /// `@_disfavoredOverload` so the `[Byte]` primary wins when both forms
    /// satisfy the call site.
    @_disfavoredOverload
    @inlinable
    public init(_ bytes: Swift.Array<UInt8>) {
        var storage = Array<Column.Shared<Byte>>()
        for byte in bytes {
            storage.append(Byte(byte))
        }
        self = Input.Slice(storage)
    }

    /// Creates a byte-stream input from a string's UTF-8 representation.
    @inlinable
    public init(utf8 string: Swift.String) {
        self.init(Swift.Array<UInt8>(string.utf8))
    }

    /// Creates an input cursor from any UInt8 collection.
    ///
    /// Stdlib-interop forwarder per [API-BYTE-006].
    @_disfavoredOverload
    @inlinable
    public init<Bytes: Swift.Collection>(_ bytes: Bytes) where Bytes.Element == UInt8 {
        self.init(Swift.Array(bytes))
    }

    /// Creates an input cursor from a UInt8 array slice.
    ///
    /// Stdlib-interop forwarder per [API-BYTE-006].
    @_disfavoredOverload
    @inlinable
    public init(_ bytes: ArraySlice<UInt8>) {
        self.init(Swift.Array(bytes))
    }

    /// Checks if the remaining bytes start with the given prefix.
    ///
    /// Delegates to ``Input/Access/Random``'s `access.starts(with:)` Property
    /// view — the canonical prefix-match operation lives on the Random-access
    /// capability protocol. This wrapper preserves the call-site shape
    /// `input.starts(with:)`; new call sites SHOULD prefer
    /// `input.access.starts(with: prefix)` directly.
    ///
    /// - Parameter prefix: The prefix to check.
    /// - Returns: `true` if the remaining bytes start with the prefix.
    @inlinable
    public func starts<Prefix: Swift.Collection>(with prefix: Prefix) -> Bool
    where Prefix.Element == Byte {
        var copy = self
        return copy.access.starts(with: prefix)
    }
}
