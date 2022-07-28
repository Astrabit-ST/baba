#ifndef DEBUG_H
#define DEBUG_H

#include "common.hpp"

void disassembleChunk(Chunk *chunk, const char *name);
int disassembleInstruction(Chunk *chunk, int offset);

#endif
