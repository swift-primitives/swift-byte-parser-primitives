# Byte Parser Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Byte-element-specific parser combinators for Swift. `Parser.Byte` matches a single byte against a streaming byte input. The package separates byte-domain parsers from the input-agnostic combinator algebra in [`swift-parser-primitives`](https://github.com/swift-primitives/swift-parser-primitives).

The API takes `Byte_Primitives.Byte` at its surface; the input stream is matched as `UInt8` because the institute reserves `UInt8` for arithmetic and `Byte` for binary-data domains.

---

## Quick Start

```swift
import Byte_Parser_Primitives

let parser = Parser.Byte<ByteInput>(0x41)   // 0x41 inferred as Byte
var input = ByteInput([0x41, 0x42, 0x43])
try parser.parse(&input)                     // input now starts at 0x42
```

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-byte-parser-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Byte Parser Primitives", package: "swift-byte-parser-primitives"),
    ]
)
```

The package is pre-1.0 — until 0.1.0 is tagged, depend on `branch: "main"` rather than `from: "0.1.0"`. Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

| Product | Target | Purpose |
|---------|--------|---------|
| `Byte Parser Primitives` | `Sources/Byte Parser Primitives/` | `Parser.Byte` — a streaming single-byte literal matcher. Output `Void`, failure `Either<Parser.EndOfInput.Error, Parser.Match.Error>`. |
| `Byte Parser Primitives Test Support` | `Tests/Support/` | Re-export spine carrying upstream Parser + Byte test support modules. |

Dependencies: `swift-parser-primitives` (for the `Parser` namespace and combinator algebra) and `swift-byte-primitives` (for the `Byte` type at the API surface).

Foundation-free.

---

## Relationship to Other Packages

- [`swift-parser-primitives`](https://github.com/swift-primitives/swift-parser-primitives) — Input-agnostic combinator algebra (Map, Filter, Many, OneOf, Take, FlatMap, …). This package depends on it.
- [`swift-byte-primitives`](https://github.com/swift-primitives/swift-byte-primitives) — The `Byte` value type. This package depends on it.
- [`swift-binary-parser-primitives`](https://github.com/swift-primitives/swift-binary-parser-primitives) — Byte-stream parsing infrastructure (Binary Input, Binary Parser core). Sibling, may later be refactored to depend on byte-parser-primitives.

---

## License

Apache License 2.0 — see [LICENSE.md](LICENSE.md).
