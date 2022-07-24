#ifndef LEXER_H
#define LEXER_H

enum TokenType
{
    tLPAREN,
    tRPAREN,
    tCOMMA,
    tMINUS,
    tPLUS,
    tSLASH,
    tSTAR,
    tSEMICOLON,
    tLBRACE,
    tRBRACE,
    tDOT,
    tMODULO,
    tNOT,
    tNEQUAL,
    tEQUAL,
    tDEQUAL,
    tGREATER,
    tLESS,
    tGEQUAL,
    tLEQUAL,
    tIDENTIFIER,
    tCONSTANT,
    tSTRING,
    tNUMBER,
    tTHING,
    tIF,
    tELSE,
    tELSIF,
    tDOES,
    tFOR,
    tBLANK,
    tOR,
    tAND,
    tRETURN,
    tSUPER,
    tSELF,
    tVAR,
    tWHILE,
    tFALSE,
    tTRUE,
    tBREAK,
    tINCLUDE,
    tSWITCH,
    tWHEN,
    tNEXT,
    tAWAIT,
    tYIELD,
    tEOF,
    tERROR
};

struct Token
{
    TokenType type;
    const char *start;
    int length;
    int line;
};

#endif
