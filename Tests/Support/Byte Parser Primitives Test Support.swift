// Byte Parser Primitives Test Support.swift
//
// Test Support is a thin re-export of the main target plus upstream Byte
// fixtures. `Byte.Input` (the canonical byte-stream input type) is defined
// in the main target (`Byte Parser Primitives`) and reaches tests via the
// re-export below — no test-specific scaffolding required.
//
// Deliberately does NOT re-export `Parser_Primitives_Test_Support` because
// the parser-primitives Test Support umbrella re-exports the legacy
// `Parser_Byte_Primitives` target — pulling the legacy and Byte.Parser
// types into the same scope would cause ambiguous-name errors during the
// overlap window. Once the legacy target is fully retired, this comment
// becomes obsolete.
