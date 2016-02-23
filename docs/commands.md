### Commands
4 word (16 bytes).
` | OP_CODE | O_ADDR | [I_ADDR_1] | [I_ADDR_2] | `

```
PUSH [a];
POP [a];
JMP [a];
MOV [a], [b]; // a = b
ADD [a], [b], [c]; // a = b + c]

JPMI [a]; // jump if C
JMPZ [a]; // jump if result of last operation -- zero
```
