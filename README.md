# simple SoC
![Build status](https://api.travis-ci.org/Corey-Maler/simple_SoC.svg)

## Overview

![SoC architecture](https://rawgithub.com/Corey-Maler/simple_SoC/master/docs/soc.svg)

### Booting process
1. Bootloader load to RAM basic input/output system, which provide some interrupts and containts programs to display strings, run programs and other.
2. Bootloader copy to memory code from SD-card
3. CPU-enabled flag it turn-on and calling RESET interrupt.

### address

|   addr     | module          | MNEMONIC | comment |
|        ---:|:---             | :--- | :--- |
| **`00_xx`** - **`10_xx`** | RAM with program and data        | | |
| `..00xxx` |  hardware interrupts | | 8 interrupts |
| `..01xxx` | software interrupts | | 8 interrupts |
| `..00000` | *reset* | | |
| `..00001` | *timer_1* | | controlled by $rt |
| **`11_xx_xx_xx_x`** | Registers, IO, stack   | | |
| `11_00_...`| | | 2 ^ 28 |
| `..0xxxx`  | User Registers  | $r0-$r15 | |
| `..10000`  | flag register   | $rf | |
| `..10001`  | timer interapt mask   | $rt | |
| `..10010`  | stack head | $st | |
| `..11001`  | digits on board | | |
| `..11100`  | GPU command     | | |
| `..11101`  | GPU data        | | |
| `11_01_...` | Stack | | 2 ^ 28|

### instruction set summary

| Mnemonic | Operands | Brief description | Flags | so |
| --- | --- | --- | --- | --- |
| ADD | z, x, y |  Add |  | z = x + y  |      |
| AND | z, x, y | Bitwise AND |  | z = x & y |
| CMN | x, y | Compare negative | | $rf[2] = x < y |
| CMP | x, y | Compare  |  | $rf[2] = x > y |
| INT | x | software interrup |  |  |
| JMP | label | jump to label | | $CP = label |
| JMPR | shift | jump relative | | $CP = $CP + shift |
| XOR | z, x, y | Exclusive or | | z = x ^ y |
| MOV | z, x | Move x to z | | z <= x |
| lsls | z, x, y | logical shift left | | z = x << y |
| lsrs | z, x, y | logical shift right | | z = x >> y |
| MUL | z, x, y | Multiply | | z = x * y |
| NOT | z, x | Bitwise NOT | | z = !x |
| NOP | - | No Operation | | |
| ORR | z, x, y | OR | | z = x \| y
| POP | r | pop register from stack | | |
| PUSH| r | push register to stack | | |
| REV | z, x | byte-reverse word | | |
| RORS | z, x, y | Rotate Right | | |
| RSVS | z, x | Reverse int | | z = 0 - x |
| SUB | z, x, y | sub | | z = x - y |
| WFI | - | Wait for Interrupt | | |


### flag register
```
[0] -- carry
[1] -- does result of last operation is zero
[2] -- last compare result
````
### Adressing:
#### Direct:
`$r0 - $r15` registers
`xxxx` RAM or direct address

#### indirect
`@r0 - @r15` registers
`@xxxx`

#### relative
`+xxxx` // don't know

#### constant
* `b1100_1111` // binary
* `o1223_3212` // octal
* `d10` // deceminal
* `h12` // hex

#### get addr
`&($xxxx | @xxxx | var_name)`


### Multi CPU and threads
Available 4 CPU with 4 threads per CPU.

Any CPU starts from `@00_00 + 4 * CPU_ID`. For example:
``` asm
x0000: h0F00; // reset (initial) address
...
x0F00: jmp CPU_1_main; // start instruction for CPU_1
x0F04: jmp CPU_2_main; // start instruction for CPU_2
x0F08: jmp h0F08; // instruction for CPU_3 (awaiting for command)
x0F0A: jmp h0F0A; // instruction for CPU_4 (awaiting for command)
```

CPU 2, 3, 4 is disabled by default;

#### Commands
``` asm
; CPU's:
 OR $cpu, b0010; // set $cpu[2] to 1 to enable CPU_2;
 AND $cpu, b1101; // set $cpu[2] to 0 to disable CPU_2;
; THREADS:
 THR_CH TH_ID; // change current thread to TH_ID. Will changes registes and stack banks.
 THR_RST TH_ID, START_ADDR; // reset TH_ID thread and set PC to START_ADDR and start thread
```

### Examples
#### Hello world
``` asm
#include stdio.asm

.DATA
_STR "Wake up, Neo\b_";

.PROGRAM
push addr(_STR);
call print;
```
