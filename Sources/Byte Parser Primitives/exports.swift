// exports.swift

@_exported public import Byte_Primitives
@_exported public import Parser_Primitives
@_exported public import Parser_EndOfInput_Primitives
@_exported public import Parser_Match_Primitives
@_exported public import Either_Primitives
// Re-export the modules that form Byte.Input's underlying shape
// (Input.Slice<Array<Byte>.Shared>). Byte.Input's @inlinable
// constructors expand the institute `Array<Byte>.Shared` and its
// Collection.Protocol conformance into caller code, and @inlinable parser APIs
// (e.g. Binary.Parser.parseWhole) carry that requirement on to leaf consumers,
// so both modules MUST stay @_exported for member-import visibility of the
// Input.Protocol / Collection.Protocol conformances.
//
// DO NOT DEMOTE Array_Primitives. Demoting it to a non-re-exported import does
// surface a real-looking "leak" — the institute `Array` becomes visible in a
// consumer's file scope and shadows `Swift.Array` (e.g. breaking
// `try Array<ASCII.Code>(bytes)` in swift-rfc-791's IPv4.Address) — but the
// re-export is load-bearing: removing it breaks binary-parser's @inlinable
// parser conformance ("cannot use conformance of 'Array<S>' to 'Protocol' … ;
// 'Array_Primitives' was not imported by this file"; verified 2026-06-30,
// supersedes 7852b97). The correct resolution is consumer-side — a file that
// hits the shadow qualifies the name (`Swift.Array<…>`).
@_exported public import Input_Primitives
@_exported public import Array_Primitives
// Re-export the cursor + index modules so consumers using `Cursor<Byte>`
// (the institute's borrowed-bytes cursor — substrate for byte parsing)
// get the substrate types in scope without an extra import.
@_exported public import Cursor_Primitives
@_exported public import Cursor_Primitive
@_exported public import Memory_Cursor_Primitives
@_exported public import Index_Primitives
