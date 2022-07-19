class BabaParser
macro
    DIGIT   [0-9]
    ALPHA   ([a-z]|_)\w*
    BLANK   ([\ \t]+|\n|\r\n)
    CONSTANT ([A-Z])\w*

rule

# [:state]  pattern  [actions]

                {BLANK}                       # No action
                {DIGIT}+(\.{DIGIT}+)?         { [:NUMBER, text.to_f] }
                \"([^"]*)\"                   { [:STRING, text]  }
                \(                            { [:LEFT_PAREN, "("] }
                \)                            { [:RIGHT_PAREN, ")"] }
                ,                             { [:COMMA, ","] }
                \-                            { [:MINUS, "-"] }
                \+                            { [:PLUS, "+"] }
                \/                            { [:SLASH, "/"] }
                \*                            { [:STAR, "*"] }
                ;                             { [:SEMICOLON, ";"] }
                \{                            { [:LEFT_BRACE, "{"] }
                \}                            { [:RIGHT_BRACE, "}"] }
                \.                            { [:DOT, "."] }
                %                             { [:MODULO, "%"] }
                !=                            { [:NOT_EQUAL, "!="] }
                !                             { [:NOT, "!"] }
                ==                            { [:EQUAL_EQUAL, "=="] }
                >=                            { [:GREATER_EQUAL, ">="] }
                <=                            { [:LESS_EQUAL, "<="] }
                =                             { [:EQUAL, "="] }
                >                             { [:GREATER, ">"] }
                <                             { [:LESS, "<"] }
                thing                         { [:THING, text] }
                if                            { [:IF, "if"] }
                else                          { [:ELSE, "else"] }
                elsif                         { [:ELSIF, "elsif"] }
                does                          { [:DOES, "does"] }
                for                           { [:FOR, "for"] }
                or                            { [:OR, "or"] }
                \|\|                          { [:OR, "||"] }
                and                           { [:AND, "and"] }
                &&                            { [:AND, "&&"] }
                return                        { [:RETURN, "return"] }
                super                         { [:SUPER, "super"] }
                self                          { [:SELF, "self"] }
                var                           { [:VAR, "var"] }
                while                         { [:WHILE, "while"] }
                false                         { [:FALSE, false] }
                true                          { [:TRUE, true] }
                break                         { [:BREAK, "break"] }
                switch                        { [:SWITCH, "switch"] }
                when                          { [:WHEN, "when"] }
                next                          { [:NEXT, "next"] }
                await                         { [:AWAIT, "await"] }
                yield                         { [:YIELD, "yield"] }
                {CONSTANT}                    { [:CONSTANT, text] }
                {ALPHA}({ALPHA}|{DIGIT})*     { [:IDENTIFIER, text] }
end
