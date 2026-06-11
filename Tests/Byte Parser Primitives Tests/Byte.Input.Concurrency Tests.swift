import Byte_Parser_Primitives_Test_Support
import Testing

// W3 rider — BYTE-PARSER's own composition under concurrency (arc-1,
// GOAL-tower-arc-shared-soundness §W3): `Byte.Input` is
// `Input.Slice<Array<Column.Shared<Byte>>>` (`7a057d5`) — a zero-copy slice
// whose VALUE SEMANTICS carry parser backtracking (attempts run on copies;
// only successes write back). The rider runs that exact discipline across
// tasks: every task backtrack-parses its own slice copy of ONE shared column
// while the source slice must stay byte-for-byte untouched. Reads share the
// box; no slice mutation ever reaches another slice.

private let basePattern: [Byte] = [0x41, 0x42, 0x43, 0x44]

private func makePattern(repeats: Int) -> [Byte] {
    var out: [Byte] = []
    out.reserveCapacity(repeats * basePattern.count)
    for _ in 0..<repeats { out.append(contentsOf: basePattern) }
    return out
}

/// A byte that can never match `expected` (comparison-built — the byte domain
/// forbids arithmetic on `Byte`).
private func mismatch(for expected: Byte) -> Byte {
    expected == 0x00 ? 0x01 : 0x00
}

@Suite
struct `Byte.Input Concurrency Tests` {

    @Test(arguments: [4, 16])
    func `concurrent backtracking parses never disturb the shared source`(width: Int) async {
        let pattern = makePattern(repeats: 10)
        let source = Byte.Input(pattern)
        let outcomes = await withTaskGroup(of: Bool.self, returning: [Bool].self) { group in
            for _ in 0..<width {
                group.addTask {
                    var mine = source                    // slice copy: shares the column box
                    var good = true
                    for expected in pattern {
                        // The backtracking discipline: the failing attempt runs on
                        // a COPY and is discarded; the slice itself never rewinds.
                        var probe = mine
                        let failed = (try? Byte.Parser<Byte.Input>(mismatch(for: expected)).parse(&probe)) == nil
                        good = good && failed
                        good = good && (mine.first == expected)
                        let advanced = (try? Byte.Parser<Byte.Input>(expected).parse(&mine)) != nil
                        good = good && advanced
                    }
                    return good && mine.isEmpty          // consumed the whole pattern
                }
            }
            var out: [Bool] = []
            for await ok in group { out.append(ok) }
            return out
        }
        #expect(outcomes.count == width)
        #expect(outcomes.allSatisfy { $0 })
        #expect(source.first == 0x41)                    // the source slice never moved
        #expect(!source.isEmpty)
    }

    @Test
    func `concurrent slices diverge by value at distinct depths`() async {
        let pattern = makePattern(repeats: 8)
        let source = Byte.Input(pattern)
        let outcomes = await withTaskGroup(of: Bool.self, returning: [Bool].self) { group in
            for depth in 0..<16 {
                group.addTask {
                    var mine = source                    // sibling slice over the same box
                    var good = true
                    for i in 0..<depth {                 // consume exactly `depth` bytes
                        let advanced = (try? Byte.Parser<Byte.Input>(pattern[i]).parse(&mine)) != nil
                        good = good && advanced
                    }
                    good = good && (mine.first == pattern[depth])
                    return good
                }
            }
            var out: [Bool] = []
            for await ok in group { out.append(ok) }
            return out
        }
        #expect(outcomes.count == 16)
        #expect(outcomes.allSatisfy { $0 })
        #expect(source.first == 0x41)                    // divergence stayed value-local
    }
}
