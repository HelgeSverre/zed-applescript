### Tree-sitter Highlights Query Example

Source: https://context7.com/tree-sitter/tree-sitter/llms.txt

An example query file for syntax highlighting, assigning capture names to different code elements like keywords, types, and strings.

```scm
; queries/highlights.scm (example for a C-like language)
"func"   @keyword
"return" @keyword
(type_identifier)            @type
(int_literal)                @number
(function_declaration
  name: (identifier) @function)
(comment)                    @comment
(string_literal)             @string
```

--------------------------------

### Tree-sitter Predicates and Directives

Source: https://context7.com/tree-sitter/tree-sitter/llms.txt

Use predicates like #eq?, #match?, and #any-of? to filter matches. Directives like #set! and #strip! associate metadata with patterns.

```scheme
; #eq? — match identifier named "self"
((identifier) @variable.builtin
  (#eq? @variable.builtin "self"))
```

```scheme
; #eq? — key-value pair where key text equals value text
((pair
  key: (property_identifier) @key
  value: (identifier) @val)
 (#eq? @key @val))
```

```scheme
; #match? — SCREAMING_SNAKE_CASE constant
((identifier) @constant
  (#match? @constant "^[A-Z][A-Z_]+"))
```

```scheme
; #not-match? — skip test files
((identifier) @fn
  (#not-match? @fn "_test$"))
```

```scheme
; #any-of? — JavaScript built-in identifiers
((identifier) @variable.builtin
  (#any-of? @variable.builtin "arguments" "module" "console" "window" "document"))
```

```scheme
; #set! — mark a comment as Doxygen injection content
((comment) @injection.content
  (#match? @injection.content "/[*][/][!*][/]?[^a-zA-Z]")
  (#set! injection.language "doxygen"))
```

```scheme
; #strip! / #select-adjacent! — strip Ruby comment chars from docstrings
(
  (comment)* @doc
  .
  (class name: (constant) @name) @definition.class
  (#strip! @doc "^#\\s*")
  (#select-adjacent! @doc @definition.class)
)
```

--------------------------------

### Find Empty Comments Using `any-eq?`

Source: https://github.com/tree-sitter/tree-sitter/blob/master/docs/src/using-parsers/queries/3-predicates-and-directives.md

The `#any-eq?` predicate is used here with a quantified capture `(comment)+` to find any comment that matches the string '//'. This is useful for identifying specific types of comments within a group.

```tree-sitter query
((comment)+ @comment.empty
  (#any-eq? @comment.empty "//"))
```

--------------------------------

### Match Builtin Variable 'self' in C

Source: https://github.com/tree-sitter/tree-sitter/blob/master/docs/src/using-parsers/queries/3-predicates-and-directives.md

Use the `#eq?` predicate to match an identifier specifically against the string 'self'. This is useful for identifying specific keywords or variables.

```tree-sitter query
((identifier) @variable.builtin
  (#eq? @variable.builtin "self"))
```

--------------------------------

### Compile and Execute S-expression Query in C

Source: https://context7.com/tree-sitter/tree-sitter/llms.txt

Compiles an S-expression pattern into a TSQuery object and executes it on a parsed tree to find and capture function definition names. Ensure the language is set correctly before parsing.

```c
#include <stdio.h>
#include <string.h>
#include <tree_sitter/api.h>

const TSLanguage *tree_sitter_c(void);

int main(void) {
    TSParser *parser = ts_parser_new();
    const TSLanguage *lang = tree_sitter_c();
    ts_parser_set_language(parser, lang);

    const char *src = "int add(int a, int b) { return a + b; }";
    TSTree *tree = ts_parser_parse_string(parser, NULL, src, strlen(src));

    // Query: capture every function definition name
    const char *pattern = "(function_definition declarator: (function_declarator declarator: (identifier) @fn.name))";
    uint32_t err_offset;
    TSQueryError err_type;
    TSQuery *query = ts_query_new(lang, pattern, strlen(pattern), &err_offset, &err_type);

    if (!query) {
        printf("Query error at byte %u (type %d)\n", err_offset, err_type);
        return 1;
    }

    // Execute and iterate captures
    TSQueryCursor *cursor = ts_query_cursor_new();
    ts_query_cursor_exec(cursor, query, ts_tree_root_node(tree));

    TSQueryMatch match;
    while (ts_query_cursor_next_match(cursor, &match)) {
        for (int i = 0; i < match.capture_count; i++) {
            TSNode node = match.captures[i].node;
            uint32_t start = ts_node_start_byte(node);
            uint32_t end   = ts_node_end_byte(node);
            printf("function name: %.*s\n", (int)(end - start), src + start);
            // function name: add
        }
    }

    ts_query_cursor_delete(cursor);
    ts_query_delete(query);
    ts_tree_delete(tree);
    ts_parser_delete(parser);
    return 0;
}

```
