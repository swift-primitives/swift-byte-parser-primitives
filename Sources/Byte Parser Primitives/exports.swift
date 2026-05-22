// exports.swift

@_exported public import Byte_Primitives
@_exported public import Parser_Primitives_Core
@_exported public import Parser_EndOfInput_Primitives
@_exported public import Parser_Match_Primitives
@_exported public import Either_Primitives
// Re-export the modules whose types form Byte.Input's underlying shape
// (Input.Slice<Array<Byte>.Indexed<Byte>>). Consumers of Byte.Input
// require these for member-import visibility of Input.Protocol /
// Collection.Protocol conformances on the underlying Input.Slice /
// Array.Indexed.
@_exported public import Input_Primitives
@_exported public import Array_Dynamic_Primitives
// Re-export the cursor + index modules so consumers using `Cursor<Byte>`
// (the institute's borrowed-bytes cursor — substrate for byte parsing)
// get the substrate types in scope without an extra import.
@_exported public import Cursor_Primitives
@_exported public import Index_Primitives
