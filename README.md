# Byte Parser Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-primitives/swift-byte-parser-primitives/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-primitives/swift-byte-parser-primitives/actions/workflows/ci.yml)

`Byte.Parser` matches a single byte against a streaming byte input — the byte-domain layer over the input-agnostic combinator algebra in [`swift-parser-primitives`](https://github.com/swift-primitives/swift-parser-primitives). It needs only forward (`Streaming`) input — no backtracking — so it is efficient on forward-only sources, and composes with every combinator (`Map`, `Many`, `OneOf`, `Take`, …) the parser algebra provides.

For fixed byte sequences, `Byte.Literal.Parser` matches a byte literal. The API takes `Byte_Primitives.Byte` at its surface — the institute reserves `UInt8` for arithmetic and `Byte` for binary-data domains — while the input stream is matched as raw bytes underneath.

---

## Key Features

- **Single-byte match** — `Byte.Parser` matches one expected `Byte`; forward-only (`Streaming`), no backtracking.
- **Byte-literal match** — `Byte.Literal.Parser` matches a fixed byte sequence.
- **Composes with the algebra** — drops into the input-agnostic combinators from `swift-parser-primitives`.
- **`Byte` at the surface** — binary-data domain typing, not `UInt8` arithmetic typing.

---

## Quick Start

```swift
import Byte_Parser_Primitives
import Parser_Primitives_Test_Support

let parser = Byte.Parser<Parser.Test.Input>(0x41)   // matches the byte 0x41
var input = Parser.Test.Input([0x41, 0x42, 0x43])
try parser.parse(&input)                            // input now starts at 0x42
```

---

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-byte-parser-primitives.git", branch: "main")
]
```

Add the product to your target:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Byte Parser Primitives", package: "swift-byte-parser-primitives")
    ]
)
```

The package is pre-1.0 — depend on `branch: "main"` until `0.1.0` is tagged. Requires Swift 6.3 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the corresponding Linux / Windows toolchain).

---

## Architecture

| Product | Contents | When to import |
|---------|----------|----------------|
| `Byte Parser Primitives` | `Byte.Parser` (single-byte matcher) and `Byte.Literal.Parser` (byte-literal matcher); failure is `Either<Parser.EndOfInput.Error, Parser.Match.Error>` | The only product — import this |

---

## Platform Support

| Platform         | CI  | Status       |
|------------------|-----|--------------|
| macOS 26         | Yes | Full support |
| Linux            | Yes | Full support |
| Windows          | Yes | Full support |
| iOS/tvOS/watchOS | —   | Supported    |
| Swift Embedded   | —   | Pending (nightly-toolchain follow-up) |

---

## Related Packages

- [`swift-parser-primitives`](https://github.com/swift-primitives/swift-parser-primitives) — the input-agnostic combinator algebra (`Map`, `Filter`, `Many`, `OneOf`, `Take`, `FlatMap`, …) these byte parsers compose with.
- [`swift-byte-primitives`](https://github.com/swift-primitives/swift-byte-primitives) — the `Byte` value type at the API surface.
- [`swift-binary-parser-primitives`](https://github.com/swift-primitives/swift-binary-parser-primitives) — byte-stream parsing infrastructure (Binary Input, Binary Parser core); a sibling.

---

## Community

<!-- BEGIN: discussion -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
