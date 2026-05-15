import Byte_Parser_Primitives_Test_Support
import Testing

// MARK: - Test Suite Structure

@Suite("Parser.Byte")
struct ParserByteTests {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension ParserByteTests.Unit {
    @Test
    func `matches expected byte and advances input`() throws {
        let parser = Parser.Byte<ByteInput>(0x41)
        var input = ByteInput([0x41, 0x42, 0x43])

        try parser.parse(&input)

        #expect(input.first == 0x42)
    }

    @Test
    func `consumes single byte from input`() throws {
        let parser = Parser.Byte<ByteInput>(0xFF)
        var input = ByteInput([0xFF])

        try parser.parse(&input)

        #expect(input.isEmpty)
    }

    @Test
    func `init takes Byte type at API surface`() throws {
        let expected: Byte = 0x42
        let parser = Parser.Byte<ByteInput>(expected)
        var input = ByteInput([0x42])

        try parser.parse(&input)

        #expect(input.isEmpty)
    }

    @Test
    func `Byte literal flows through ExpressibleByIntegerLiteral`() throws {
        // 0x55 must infer as Byte (not UInt8) at the call site.
        let parser = Parser.Byte<ByteInput>(0x55)
        var input = ByteInput([0x55])
        try parser.parse(&input)
        #expect(input.isEmpty)
    }
}

// MARK: - Edge Case Tests

extension ParserByteTests.`Edge Case` {
    @Test
    func `fails on empty input with EndOfInput error`() {
        let parser = Parser.Byte<ByteInput>(0x41)
        var input = ByteInput([])

        #expect {
            try parser.parse(&input)
        } throws: { error in
            guard let either = error as? Either<Parser.EndOfInput.Error, Parser.Match.Error> else {
                return false
            }
            return either.left != nil
        }
    }

    @Test
    func `fails on wrong byte with Match error`() {
        let parser = Parser.Byte<ByteInput>(0x41)
        var input = ByteInput([0x42])

        #expect {
            try parser.parse(&input)
        } throws: { error in
            guard let either = error as? Either<Parser.EndOfInput.Error, Parser.Match.Error> else {
                return false
            }
            return either.right != nil
        }
    }

    @Test
    func `zero byte parses correctly`() throws {
        let parser = Parser.Byte<ByteInput>(0x00)
        var input = ByteInput([0x00, 0x01])
        try parser.parse(&input)
        #expect(input.first == 0x01)
    }

    @Test
    func `max byte parses correctly`() throws {
        let parser = Parser.Byte<ByteInput>(0xFF)
        var input = ByteInput([0xFF])
        try parser.parse(&input)
        #expect(input.isEmpty)
    }
}

// MARK: - Integration Tests

extension ParserByteTests.Integration {
    @Test
    func `Byte.zero constant flows through parser init`() throws {
        let parser = Parser.Byte<ByteInput>(Byte.zero)
        var input = ByteInput([0x00])
        try parser.parse(&input)
        #expect(input.isEmpty)
    }

    @Test
    func `Byte.max constant flows through parser init`() throws {
        let parser = Parser.Byte<ByteInput>(Byte.max)
        var input = ByteInput([0xFF])
        try parser.parse(&input)
        #expect(input.isEmpty)
    }
}

// MARK: - Performance Tests

extension ParserByteTests.Performance {
    @Test
    func `parse all 256 byte values`() throws {
        for i: UInt8 in 0...255 {
            let parser = Parser.Byte<ByteInput>(Byte(i))
            var input = ByteInput([i])
            try parser.parse(&input)
            #expect(input.isEmpty)
        }
    }
}
