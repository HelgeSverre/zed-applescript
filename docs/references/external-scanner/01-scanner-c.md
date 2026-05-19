### TSLexer Struct

Source: https://github.com/tree-sitter/tree-sitter/blob/master/docs/src/creating-parsers/4-external-scanners.md

The `TSLexer` struct provides the necessary interface for the external scanner to interact with the input stream, recognize tokens, and manage lexer state.

```APIDOC
## TSLexer Struct Fields

### Description
The `TSLexer` struct contains fields and function pointers that the external scanner uses to process input and identify tokens.

### Fields
- **`int32_t lookahead`** - The current next character in the input stream, represented as a 32-bit unicode code point. A value of `0` typically indicates the end of the file, but `eof()` should be used for reliable checking.
- **`TSSymbol result_symbol`** - The symbol (token type) that was recognized by the scanner. This field should be assigned a value from the `TokenType` enum.

### Methods
- **`void (*advance)(TSLexer *, bool skip)`** - Advances the lexer to the next character. If `skip` is `true`, the current character is treated as whitespace and will not be included in the token's text range.
- **`void (*mark_end)(TSLexer *)`** - Marks the end of the current token. Subsequent calls to `advance` will not increase the token's size beyond this point. Can be called multiple times to extend the token's boundary.
- **`uint32_t (*get_column)(TSLexer *)`** - Returns the current column position (number of codepoints since the start of the line).
- **`bool (*is_at_included_range_start)(const TSLexer *)`** - Checks if the parser has just skipped characters, relevant for parsing embedded documents.
- **`bool (*eof)(const TSLexer *)`** - Returns `true` if the lexer is at the end of the input file, `false` otherwise.
```

--------------------------------

### External Scanner Scan Function

Source: https://github.com/tree-sitter/tree-sitter/blob/master/docs/src/creating-parsers/4-external-scanners.md

The `tree_sitter_my_language_external_scanner_scan` function is the entry point for the external scanner. It is responsible for lexing tokens based on the provided lexer state and valid symbols.

```APIDOC
## Scan Function Signature

### Description
This function is called by the Tree-sitter parser to lex tokens when an external scanner is enabled. It should return `true` if a token was successfully lexed, and `false` otherwise.

### Method
C Function

### Endpoint
N/A (Internal function)

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

### Parameters
- **payload** (`void *`) - Optional user-defined data passed to the scanner.
- **lexer** (`TSLexer *`) - A pointer to the `TSLexer` struct, which provides methods for interacting with the input stream and managing token recognition.
- **valid_symbols** (`const bool *`) - An array of booleans indicating which external tokens are expected by the parser. The scanner should only attempt to recognize tokens that are marked as valid in this array.

### Request Example
```c
bool tree_sitter_my_language_external_scanner_scan(
  void *payload,
  TSLexer *lexer,
  const bool *valid_symbols
) {
  // ... implementation ...
  return true; // or false if no token was lexed
}
```

### Response
#### Success Response (true)
Indicates that a token was successfully lexed.

#### Error Response (false)
Indicates that no token could be lexed by the external scanner at the current position.

#### Response Example
`true` or `false`
```

--------------------------------

### External Scanner C Implementation

Source: https://github.com/tree-sitter/tree-sitter/blob/master/docs/src/creating-parsers/4-external-scanners.md

This section details the C implementation required for an external scanner, including the token enum and the five core functions.

```APIDOC
## External Scanner C Implementation

### Description
Implement the external scanner logic in a `src/scanner.c` file. This involves defining a token enum and five specific C functions: `create`, `destroy`, `serialize`, `deserialize`, and `scan`.

### Method
N/A (C Implementation)

### Endpoint
N/A (C Implementation)

### Parameters
N/A

### Request Example
#### Token Enum Definition
```c
#include "tree_sitter/parser.h"
#include "tree_sitter/alloc.h"
#include "tree_sitter/array.h"

enum TokenType {
  INDENT,
  DEDENT,
  NEWLINE
};
```

#### `create` Function
```c
void * tree_sitter_my_language_external_scanner_create() {
  // Allocate and initialize scanner state
  // Return a pointer to the scanner state, or NULL if no state is needed
  return NULL; 
}
```

#### `destroy` Function
```c
void tree_sitter_my_language_external_scanner_destroy(void *payload) {
  // Free any memory allocated by the create function
}
```

#### `serialize` Function
```c
unsigned tree_sitter_my_language_external_scanner_serialize(
  void *payload,
  char *buffer
) {
  // Copy scanner state to buffer
  // Return the number of bytes written
  return 0;
}
```

#### `deserialize` Function
```c
void tree_sitter_my_language_external_scanner_deserialize(
  void *payload,
  const char *buffer,
  unsigned length
) {
  // Restore scanner state from buffer
}
```

### Response
N/A
```

--------------------------------

### Handling Valid Symbols in External Scanner

Source: https://github.com/tree-sitter/tree-sitter/blob/master/docs/src/creating-parsers/4-external-scanners.md

This example shows how to conditionally lex tokens based on the `valid_symbols` array. You should only attempt to lex a symbol if it is indicated as valid by the parser.

```c
if (valid_symbols[INDENT] || valid_symbols[DEDENT]) {

  // ... logic that is common to both `INDENT` and `DEDENT`

  if (valid_symbols[INDENT]) {

    // ... logic that is specific to `INDENT`

    lexer->result_symbol = INDENT;
    return true;
  }
}
```

--------------------------------

### Handling Valid Symbols

Source: https://github.com/tree-sitter/tree-sitter/blob/master/docs/src/creating-parsers/4-external-scanners.md

The `valid_symbols` array informs the scanner which tokens the parser is currently expecting. The scanner should only attempt to lex tokens that are marked as valid.

```APIDOC
## Using `valid_symbols`

### Description
The `valid_symbols` array is crucial for efficient scanning. It prevents the scanner from performing unnecessary work by only attempting to recognize tokens that the parser requires.

### Usage
Iterate through the `valid_symbols` array. If `valid_symbols[SYMBOL_TYPE]` is `true`, then the parser expects a token of type `SYMBOL_TYPE`. The scanner should then attempt to lex that token. Note that the scanner cannot backtrack, so logic might need to be combined if multiple symbols are valid.

### Example
```c
if (valid_symbols[INDENT] || valid_symbols[DEDENT]) {
  // Logic common to both INDENT and DEDENT

  if (valid_symbols[INDENT]) {
    // Logic specific to INDENT
    lexer->result_symbol = INDENT;
    return true;
  }
  // Potentially handle DEDENT here if it's also valid and not handled above
}
```
```
