import Byte_Parser_Primitives_Test_Support
import Testing

// MARK: - Cursor<Byte> byte-domain extension tests
//
// `Cursor<Byte>` is the institute's borrowed-bytes cursor. The Cursor-native
// API (peek/peek(at:)/consume/advance/position/isAtEnd) is exercised by
// swift-cursor-primitives' own test suite; this file tests the byte-domain
// surface that lives ONLY in byte-parser-primitives:
//
//   • `starts(with:)`               — typed-prefix match against a Byte sequence
//   • `copyToOwned() -> Byte.Input` — borrowed → owned conversion
//
// Plus one integration test exercising the byte parser pattern (Cursor<Byte>
// consumed for a fixed-width-integer parse) to confirm the substrate works
// end-to-end at the byte-parser-primitives layer.
//
// Note: `Cursor<Byte>` is `~Copyable` and `~Escapable`, so tests must extract
// values before using `#expect` since the macro doesn't support these types.

@Suite("Cursor<Byte>")
struct CursorByteTests {
    @Suite struct `Starts With` {}
    @Suite struct `Copy To Owned` {}
    @Suite struct Integration {}
}

// MARK: - starts(with:)

extension CursorByteTests.`Starts With` {

    @Test
    func `returns true for matching prefix`() {
        let bytes: [Byte] = [0x01, 0x02, 0x03, 0x04]

        let result = bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            let view = Cursor<Byte>(span)
            return view.starts(with: [0x01, 0x02] as [Byte])
        }

        #expect(result)
    }

    @Test
    func `returns false for non-matching prefix`() {
        let bytes: [Byte] = [0x01, 0x02, 0x03]

        let result = bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            let view = Cursor<Byte>(span)
            return view.starts(with: [0x01, 0x03] as [Byte])
        }

        #expect(!result)
    }

    @Test
    func `returns true for empty prefix on any view`() {
        let bytes: [Byte] = [0x01, 0x02]

        let result = bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            let view = Cursor<Byte>(span)
            return view.starts(with: [] as [Byte])
        }

        #expect(result)
    }

    @Test
    func `returns false when prefix exceeds remaining`() {
        let bytes: [Byte] = [0x01]

        let result = bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            let view = Cursor<Byte>(span)
            return view.starts(with: [0x01, 0x02] as [Byte])
        }

        #expect(!result)
    }
}

// MARK: - copyToOwned()

extension CursorByteTests.`Copy To Owned` {

    @Test
    func `creates independent owned input from fresh view`() {
        let bytes: [Byte] = [0x01, 0x02, 0x03, 0x04]

        let (ownedCount, ownedFirst) = bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            let view = Cursor<Byte>(span)
            let owned = view.copyToOwned()
            return (owned.count, owned.first)
        }

        #expect(ownedCount == 4)
        #expect(ownedFirst == 0x01)
    }

    @Test
    func `copies only the remaining bytes after partial consumption`() {
        let bytes: [Byte] = [0x01, 0x02, 0x03, 0x04]

        let (ownedCount, ownedFirst) = bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            var view = Cursor<Byte>(span)

            _ = view.consume()
            let owned = view.copyToOwned()

            return (owned.count, owned.first)
        }

        #expect(ownedCount == 3)
        #expect(ownedFirst == 0x02)
    }
}

// MARK: - Integration

extension CursorByteTests.Integration {

    @Test
    func `parse fixed-width integer via Cursor`() {
        let bytes: [Byte] = [0xDE, 0xAD, 0xBE, 0xEF]

        let (value, isAtEnd) = bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            var view = Cursor<Byte>(span)

            let b0 = view.consume().underlying
            let b1 = view.consume().underlying
            let b2 = view.consume().underlying
            let b3 = view.consume().underlying

            let value =
                UInt32(b0) << 24
                | UInt32(b1) << 16
                | UInt32(b2) << 8
                | UInt32(b3)

            return (value, view.isAtEnd)
        }

        #expect(value == 0xDEAD_BEEF)
        #expect(isAtEnd)
    }
}
