// exports.swift

@_exported public import Byte_Primitives
@_exported public import Parser_Primitives
@_exported public import Parser_EndOfInput_Primitives
@_exported public import Parser_Match_Primitives
@_exported public import Either_Primitives
// Re-export Input_Primitives: it supplies Byte.Input's underlying shape
// (Input.Slice<…>) and the Input.Protocol / Input.Streaming conformances on
// Input.Slice that Byte.Input consumers require for member-import visibility.
@_exported public import Input_Primitives
// [re-export hygiene] Array_Primitives is intentionally NOT @_exported here.
// @_exported-re-exporting it leaked the institute `Array` type into every
// transitive consumer's unqualified file scope, where it shadowed `Swift.Array`
// and broke byte→ASCII type-ups such as `try Array<ASCII.Code>(bytes)` — failing
// with "type 'ASCII.Code' does not conform to protocol '__BufferProtocol'" — in
// downstream RFC packages (e.g. swift-rfc-791's folded IPv4.Address). The
// institute `Array` and its `Collection.Protocol` conformance on
// `Array<Column.Shared<Byte>>` (Byte.Input's substrate) stay part of this
// module's public interface via `Byte.Input.swift`'s own `public import
// Array_Primitives`, so Byte.Input consumers keep what they need without the
// shadowing name re-export.
// Re-export the cursor + index modules so consumers using `Cursor<Byte>`
// (the institute's borrowed-bytes cursor — substrate for byte parsing)
// get the substrate types in scope without an extra import.
@_exported public import Cursor_Primitives
@_exported public import Cursor_Primitive
@_exported public import Memory_Cursor_Primitives
@_exported public import Index_Primitives
