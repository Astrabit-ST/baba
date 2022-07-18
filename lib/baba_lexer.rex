class BabaParser
macro
    DIGIT   [0-9]
    ALPHA   ([a-z]|_)\w*
    BLANK   ([\ \t]+|\n)
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
                \}                            { state = previous; [:RIGHT_BRACE, "}"] }
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
                does                          { previous = state; state = :function; [:DOES, "does"] }
                for                           { previous = state; state = :breakable; [:FOR, "for"] }
                or                            { [:OR, "or"] }
                \|\|                          { [:OR, "||"] }
                and                           { [:AND, "and"] }
                &&                            { [:AND, "&&"] }
    :function   return                        { [:RETURN, "return"] }
    :function   super                         { [:SUPER, "super"] }
    :function   self                          { [:SELF, "self"] }
                var                           { [:VAR, "var"] }
                while                         { previous = :state; state = :breakable; [:WHILE, "while"] }
                false                         { [:FALSE, false] }
                true                          { [:TRUE, true] }
    :breakable  break                         { [:BREAK, "break"] }
                switch                        { [:SWITCH, "switch"] }
                when                          { [:WHEN, "when"] }
    :breakable  next                          { [:NEXT, "next"] }
                await                         { [:AWAIT, "await"] }
                yield                         { [:YIELD, "yield"] }
                {CONSTANT}                    { [:CONSTANT, text] }
                {ALPHA}({ALPHA}|{DIGIT})*     { [:IDENTIFIER, text] }


inner
    attr_accessor :previous

    def tokenize(code)
        scan_setup(code)
        tokens = []
        while token = next_token
            tokens << token
        end
        tokens
    end
end
