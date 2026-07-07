import Byte_Parser_Primitives_Test_Support
import Testing

// MARK: - Test Suite Structure

@Suite
struct `Byte.Literal.Parser Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension `Byte.Literal.Parser Tests`.Unit {
    @Test
    func `matches byte sequence and advances input`() throws(Byte.Literal.Parser<Byte.Input>.Failure) {
        let parser = Byte.Literal.Parser<Byte.Input>([0x48, 0x65, 0x6C])
        var input = Byte.Input([0x48, 0x65, 0x6C, 0x6C, 0x6F])

        try parser.parse(&input)

        #expect(input.first == 0x6C)
    }

    @Test
    func `string literal construction matches UTF-8 bytes`() throws(Byte.Literal.Parser<Byte.Input>.Failure) {
        let parser: Byte.Literal.Parser<Byte.Input> = "OK"
        var input = Byte.Input(utf8: "OK!")

        try parser.parse(&input)

        #expect(input.first == Byte(UInt8(ascii: "!")))
    }

    @Test
    func `exact match consumes all input`() throws(Byte.Literal.Parser<Byte.Input>.Failure) {
        let parser: Byte.Literal.Parser<Byte.Input> = "end"
        var input = Byte.Input(utf8: "end")

        try parser.parse(&input)

        #expect(input.isEmpty)
    }
}

// MARK: - Edge Case Tests

extension `Byte.Literal.Parser Tests`.`Edge Case` {
    @Test
    func `empty literal matches without consuming`() throws(Byte.Literal.Parser<Byte.Input>.Failure) {
        let parser = Byte.Literal.Parser<Byte.Input>([])
        var input = Byte.Input([0x01, 0x02])

        try parser.parse(&input)

        #expect(input.first == 0x01)
    }

    @Test
    func `fails on empty input`() {
        let parser: Byte.Literal.Parser<Byte.Input> = "x"
        var input = Byte.Input([])

        #expect(throws: Byte.Literal.Parser<Byte.Input>.Failure.self) {
            try parser.parse(&input)
        }
    }

    @Test
    func `fails on partial match`() {
        let parser: Byte.Literal.Parser<Byte.Input> = "abc"
        var input = Byte.Input(utf8: "abx")

        #expect(throws: Byte.Literal.Parser<Byte.Input>.Failure.self) {
            try parser.parse(&input)
        }
    }
}

// MARK: - Integration Tests

extension `Byte.Literal.Parser Tests`.Integration {
    @Test
    func `Byte.Literal.Parser composes with Byte.Parser`() throws(Byte.Literal.Parser<Byte.Input>.Failure) {
        let prefix: Byte.Literal.Parser<Byte.Input> = "hi"
        let suffix = Byte.Parser<Byte.Input>(0x21)  // '!'
        var input = Byte.Input(utf8: "hi!")

        try prefix.parse(&input)
        try suffix.parse(&input)

        #expect(input.isEmpty)
    }

    @Test
    func `parses long literal`() throws(Byte.Literal.Parser<Byte.Input>.Failure) {
        let bytes = Swift.Array(repeating: Byte(0x61), count: 1024)
        let parser = Byte.Literal.Parser<Byte.Input>(bytes)
        var input = Byte.Input(bytes)

        try parser.parse(&input)

        #expect(input.isEmpty)
    }
}
