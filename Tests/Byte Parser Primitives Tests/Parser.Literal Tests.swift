import Byte_Parser_Primitives_Test_Support
import Testing

// MARK: - Test Suite Structure

@Suite("Parser.Literal")
struct ParserLiteralTests {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension ParserLiteralTests.Unit {
    @Test
    func `matches byte sequence and advances input`() throws {
        let parser = Parser.Literal<ByteInput>([0x48, 0x65, 0x6C])
        var input = ByteInput([0x48, 0x65, 0x6C, 0x6C, 0x6F])

        try parser.parse(&input)

        #expect(input.first == 0x6C)
    }

    @Test
    func `string literal construction matches UTF-8 bytes`() throws {
        let parser: Parser.Literal<ByteInput> = "OK"
        var input = ByteInput(utf8: "OK!")

        try parser.parse(&input)

        #expect(input.first == UInt8(ascii: "!"))
    }

    @Test
    func `exact match consumes all input`() throws {
        let parser: Parser.Literal<ByteInput> = "end"
        var input = ByteInput(utf8: "end")

        try parser.parse(&input)

        #expect(input.isEmpty)
    }
}

// MARK: - Edge Case Tests

extension ParserLiteralTests.`Edge Case` {
    @Test
    func `empty literal matches without consuming`() throws {
        let parser = Parser.Literal<ByteInput>([])
        var input = ByteInput([0x01, 0x02])

        try parser.parse(&input)

        #expect(input.first == 0x01)
    }

    @Test
    func `fails on empty input`() {
        let parser: Parser.Literal<ByteInput> = "x"
        var input = ByteInput([])

        #expect(throws: (any Swift.Error).self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `fails on partial match`() {
        let parser: Parser.Literal<ByteInput> = "abc"
        var input = ByteInput(utf8: "abx")

        #expect(throws: (any Swift.Error).self) {
            try parser.parse(&input)
        }
    }
}

// MARK: - Integration

extension ParserLiteralTests.Integration {
    @Test
    func `Parser.Literal composes with Parser.Byte`() throws {
        let prefix: Parser.Literal<ByteInput> = "hi"
        let suffix = Parser.Byte<ByteInput>(0x21) // '!'
        var input = ByteInput(utf8: "hi!")

        try prefix.parse(&input)
        try suffix.parse(&input)

        #expect(input.isEmpty)
    }
}

// MARK: - Performance

extension ParserLiteralTests.Performance {
    @Test
    func `parses long literal`() throws {
        let bytes = Swift.Array(repeating: UInt8(0x61), count: 1024)
        let parser = Parser.Literal<ByteInput>(bytes)
        var input = ByteInput(bytes)

        try parser.parse(&input)

        #expect(input.isEmpty)
    }
}
