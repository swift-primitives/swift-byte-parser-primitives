// Byte Parser Primitives Test Support.swift
//
// Self-contained byte-stream input scaffolding for tests of byte-element
// parsers. Deliberately does NOT re-export `Parser_Primitives_Test_Support`
// because that module's umbrella also re-exports the legacy
// `Parser_Byte_Primitives` target in swift-parser-primitives — pulling
// both `Parser.Byte` types into scope causes ambiguous-name compile
// errors during the Wave-2 → Wave-3 overlap window.
//
// Wave 3 removes the legacy `Parser.Byte` and this scaffolding can be
// reconsidered: either kept as the canonical byte-stream test input for
// the byte-parser ecosystem, or replaced by re-exporting the parser-
// primitives Test Support directly.

public import Collection_Primitives
public import Input_Primitives
public import Index_Primitives
internal import Cardinal_Primitives
internal import Sequence_Primitives

// MARK: - ByteIterator

/// Iterator over `[UInt8]` for byte-stream parser tests. Conforms to
/// `Sequence.Iterator.\`Protocol\`` so it composes with the parser
/// combinator infrastructure.
public struct ByteIterator: Sequence.Iterator.`Protocol`, IteratorProtocol, Sendable {
    @usableFromInline
    var _elements: [UInt8]

    @usableFromInline
    var _index: Int

    @inlinable
    public init(_ array: [UInt8]) {
        self._elements = array
        self._index = 0
    }

    @_lifetime(&self)
    @inlinable
    public mutating func nextSpan(maximumCount: Cardinal) -> Swift.Span<UInt8> {
        let remaining = _elements.count - _index
        let take = min(Int(maximumCount.rawValue), remaining)
        guard take > 0 else { return _elements.span.extracting(first: 0) }
        let start = _index
        _index += take
        return _elements.span
            .extracting(droppingFirst: start)
            .extracting(first: take)
    }

    @inlinable
    public mutating func next() -> UInt8? {
        guard _index < _elements.count else { return nil }
        defer { _index += 1 }
        return _elements[_index]
    }
}

// MARK: - TestBytes

/// Minimal `Collection.\`Protocol\`` conformer wrapping `[UInt8]` for byte
/// parser tests. Distinct from `swift-parser-primitives`' identically-named
/// type to keep this module self-contained.
public struct TestBytes: Collection.`Protocol`, Sendable {
    public let storage: [UInt8]

    public typealias Index = Index_Primitives.Index<UInt8>

    public init(_ bytes: [UInt8]) {
        self.storage = bytes
    }

    public var startIndex: Index { .zero }

    public var endIndex: Index {
        Index.Count(Cardinal(UInt(storage.count))).map(Ordinal.init)
    }

    public subscript(position: Index) -> UInt8 {
        storage[Int(bitPattern: position)]
    }

    public func index(after i: Index) -> Index {
        try! i.successor.exact()
    }

    public func makeIterator() -> ByteIterator {
        ByteIterator(storage)
    }
}

// MARK: - ByteInput

/// Byte-oriented cursor input for testing byte parsers.
public typealias ByteInput = Input.Slice<TestBytes>

// MARK: - ExpressibleByArrayLiteral

extension Input.Slice: @retroactive ExpressibleByArrayLiteral
where Base == TestBytes {
    public init(arrayLiteral elements: UInt8...) {
        self.init(TestBytes(elements))
    }
}

// MARK: - Convenience Initializers

extension Input.Slice where Base == TestBytes {
    /// Creates a byte input from raw bytes.
    public init(_ bytes: [UInt8]) {
        self.init(TestBytes(bytes))
    }

    /// Creates a byte input from a string's UTF-8 representation.
    public init(utf8 string: Swift.String) {
        self.init(TestBytes(Swift.Array<UInt8>(string.utf8)))
    }
}
