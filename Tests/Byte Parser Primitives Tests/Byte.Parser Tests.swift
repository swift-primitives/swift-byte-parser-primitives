import Byte_Parser_Primitives_Test_Support
import Testing

// MARK: - Test Suite Structure
//
// Compound name backticked per the institute test-suite convention
// (matches swift-carrier-primitives' `Carrier Tests` — backticked
// compound names are accepted by [SWIFT-TEST-002]; bare compound names
// are not).

@Suite
struct `Byte.Parser Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

// MARK: - Unit Tests

extension `Byte.Parser Tests`.Unit {
    @Test
    func `matches expected byte and advances input`() throws(Byte.Parser<Byte.Input>.Failure) {
        let parser = Byte.Parser<Byte.Input>(0x41)
        var input = Byte.Input([0x41, 0x42, 0x43])

        try parser.parse(&input)

        #expect(input.first == 0x42)
    }

    @Test
    func `consumes single byte from input`() throws(Byte.Parser<Byte.Input>.Failure) {
        let parser = Byte.Parser<Byte.Input>(0xFF)
        var input = Byte.Input([0xFF])

        try parser.parse(&input)

        #expect(input.isEmpty)
    }

    @Test
    func `init takes Byte type at API surface`() throws(Byte.Parser<Byte.Input>.Failure) {
        let expected: Byte = 0x42
        let parser = Byte.Parser<Byte.Input>(expected)
        var input = Byte.Input([0x42])

        try parser.parse(&input)

        #expect(input.isEmpty)
    }

    @Test
    func `Byte literal flows through ExpressibleByIntegerLiteral`() throws(Byte.Parser<Byte.Input>.Failure) {
        // 0x55 must infer as Byte (not UInt8) at the call site.
        let parser = Byte.Parser<Byte.Input>(0x55)
        var input = Byte.Input([0x55])
        try parser.parse(&input)
        #expect(input.isEmpty)
    }
}

// MARK: - Edge Case Tests

extension `Byte.Parser Tests`.`Edge Case` {
    @Test
    func `fails on empty input with EndOfInput error`() {
        let parser = Byte.Parser<Byte.Input>(0x41)
        var input = Byte.Input([])

        #expect {
            try parser.parse(&input)
        } throws: { error in
            guard let either = error as? Byte.Parser<Byte.Input>.Failure else {
                return false
            }
            return either.left != nil
        }
    }

    @Test
    func `fails on wrong byte with Match error`() {
        let parser = Byte.Parser<Byte.Input>(0x41)
        var input = Byte.Input([0x42])

        #expect {
            try parser.parse(&input)
        } throws: { error in
            guard let either = error as? Byte.Parser<Byte.Input>.Failure else {
                return false
            }
            return either.right != nil
        }
    }

    @Test
    func `zero byte parses correctly`() throws(Byte.Parser<Byte.Input>.Failure) {
        let parser = Byte.Parser<Byte.Input>(0x00)
        var input = Byte.Input([0x00, 0x01])
        try parser.parse(&input)
        #expect(input.first == 0x01)
    }

    @Test
    func `max byte parses correctly`() throws(Byte.Parser<Byte.Input>.Failure) {
        let parser = Byte.Parser<Byte.Input>(0xFF)
        var input = Byte.Input([0xFF])
        try parser.parse(&input)
        #expect(input.isEmpty)
    }
}

// MARK: - Integration Tests

extension `Byte.Parser Tests`.Integration {
    @Test
    func `Byte.zero constant flows through parser init`() throws(Byte.Parser<Byte.Input>.Failure) {
        let parser = Byte.Parser<Byte.Input>(Byte.zero)
        var input = Byte.Input([0x00])
        try parser.parse(&input)
        #expect(input.isEmpty)
    }

    @Test
    func `Byte.max constant flows through parser init`() throws(Byte.Parser<Byte.Input>.Failure) {
        let parser = Byte.Parser<Byte.Input>(Byte.max)
        var input = Byte.Input([0xFF])
        try parser.parse(&input)
        #expect(input.isEmpty)
    }

    @Test(arguments: UInt8.min...UInt8.max)
    func `parses byte value`(_ i: UInt8) throws(Byte.Parser<Byte.Input>.Failure) {
        let parser = Byte.Parser<Byte.Input>(Byte(i))
        var input = Byte.Input([i])
        try parser.parse(&input)
        #expect(input.isEmpty)
    }
}
