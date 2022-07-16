class Baba
  # Single character tokens
  LEFT_PAREN = 0 # (
  RIGHT_PAREN = 1 # )
  COMMA = 2 # ,
  MINUS = 3 # -
  PLUS = 4 # +
  SLASH = 5 # /
  STAR = 6 # *
  SEMICOLON = 7 # ;
  COLON = 39 # : colons are used when marking a new statement
  DOT = 44 # .
  MODULO = 54 # %

  # One-two character tokens
  NOT = 8 # ! OR not
  NOT_EQUAL = 9 # != OR not-equal
  EQUAL = 10 # is OR =
  EQUAL_EQUAL = 11 # == OR equals
  GREATER = 12 # > OR greater
  LESS = 13 # < OR less
  GREATER_EQUAL = 14 # >= greater-equal
  LESS_EQUAL = 15 # <= less-equal

  # Literals
  IDENTIFIER = 16 # ??
  STRING = 17 # ""
  NUMBER = 18 # 0-9 0.0 etc

  # Keywords
  THING = 19 # thing (class  basically)
  IF = 20 # if
  ELSE = 21 # else
  DOES = 22 # does (method definition)
  FOR = 23 # for
  BLANK = 24 # blank
  OR = 25 # or OR ||
  AND = 26 # and OR &&
  RETURN = 27 # return
  SUPER = 28 # super
  SELF = 29 # self
  VAR = 30 # variable
  WHILE = 31 # while
  FALSE = 32 # false
  TRUE = 33 # true
  KEND = 38 # end, can also function as }
  BREAK = 42 # break
  INCLUDE = 48 # include
  SWITCH = 51 # switch
  WHEN = 52 # when
  NEXT = 53 # next

  # Special, these are more like weird functions
  AWAIT = 49 # await
  YIELD = 50 # yield

  EOF = 37

  # There are too many of these lol
  KEYWORDS = {
    "thing" => THING,
    "if" => IF,
    "else" => ELSE,
    "does" => DOES,
    "for" => FOR,

    "blank" => BLANK,

    "or" => OR,
    "||" => OR,

    "and" => AND,
    "&&" => AND,

    "return" => RETURN,
    "super" => SUPER,
    "self" => SELF,
    "var" => VAR,
    "while" => WHILE,
    "false" => FALSE,
    "true" => TRUE,
    "end" => KEND, # It's KEND because ruby is dumb
    "break" => BREAK,
    "next" => NEXT,

    "include" => INCLUDE,

    "not" => NOT,
    "not-equals" => NOT_EQUAL,
    "is" => EQUAL,
    "equals" => EQUAL_EQUAL,
    "greater" => GREATER,
    "less" => LESS,
    "greater-equal" => GREATER_EQUAL,
    "less-equal" => LESS_EQUAL,

    "switch" => SWITCH,
    "when" => WHEN,

    "await" => AWAIT,
    "yield" => YIELD,
  }
end
