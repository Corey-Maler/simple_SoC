# simple SoC
[![Build status](https://api.travis-ci.org/Corey-Maler/simple_SoC.svg)](https://travis-ci.org/Corey-Maler/simple_SoC)

## SoC architecture overview

![SoC architecture](https://rawgithub.com/Corey-Maler/simple_SoC/master/docs/soc.svg)


Read [HellyRISC architecture overview](https://github.com/Corey-Maler/simple_SoC/blob/
master/docs/HellyRISC.md)

### Booting process
1. Bootloader load to RAM basic input/output system, which provide some interrupts and containts programs to display strings, run programs and other.
2. Bootloader copy to memory code from SD-card
3. CPU-enabled flag it turn-on and calling RESET interrupt.

### Addresses map

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

| Mnemonic | Operands | Brief description | Flags | Operation |
| --- | --- | --- | --- | --- |
| ADD | z, x, y |  Add |  | z = x + y  |      |
| AND | z, x, y | Bitwise AND |  | z = x & y |
| BRN | label | Branch | | $CP = label |
| BRNR | shift | Branch relative | $CP = $CP + shift |
| BRL | label | Branch and link | | $LR = $CP; $CP = label |
| BRLR | shift | Branch and link relative | | $LR = $CP; $CP = $CP + shift |
| CMN | x, y | Compare soft (bigger or equal)| | $rf[2] = x >= y |
| CMP | x, y | Compare  |  | $rf[2] = x > y |
| INT | x | software interrup |  |  |
| XOR | z, x, y | Exclusive or | | z = x ^ y |
| MOV | z, x | Move x to z | | z <= x |
| lsls | z, x, y | logical shift left | | z = x << y |
| lsrs | z, x, y | logical shift right | | z = x >> y |
| MUL | z, x, y | Multiply | | z = x * y |
| NOT | z, x | Bitwise NOT | | z = !x |
| NOP | - | No Operation | | |
| ORR | z, x, y | OR | | z = x \| y |
| POP | r | pop register from stack | | |
| PUSH| r | push register to stack | | |
| REV | z, x | byte-reverse word | | |
| RORS | z, x, y | Rotate Right | | |
| RSVS | z, x | Reverse int | | z = 0 - x |
| SUB | z, x, y | sub | | z = x - y |
| WFI | - | Wait for Interrupt | | |

#### Conditions
All instructions can have a postfix

```
_c - skip if $rf[0] is false
_z - skip if $rf[1] is false
_e - skip if $rf[2] is false
_m - skip if $rf[3] is false
_g - skip if $rf[4] is false
_n - skip if $rf[5] is false
```

#### Flag register
```
[0] -- carry
[1] -- does result of last operation is zero
[2] -- equal
[3] -- overflow (last operator was mult and mult_h is zeros)
[4] -- greate
[5] -- negative
```

#### Instruction structure

```
0
1
2    is ALU command

3 |
  |  command
8 |

10 |
   | postfix conditions
15 |   

26   absolute/relative z
27   absolute/relative x
28   absolute/relative y 
29   direct/indirect z
30   direct/indirect x
31   direct/indirect y
```

### Adressing:
#### Direct:
`$r0 - $r15` registers
`xxxx` RAM or direct address

#### indirect
`@r0 - @r15` registers
`@xxxx`

#### relative
`+xxxx`

```
+s -- relative to $SP | 0000_xxx
+p -- relative to $PC | 1000_xxx
```

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
 OR  $cpu, b0010 ;  set $cpu[2] to 1 to enable CPU_2;
 AND $cpu, b1101 ;  set $cpu[2] to 0 to disable CPU_2;
; THREADS:
 THR_CH   TH_ID ;  change current thread to TH_ID. Will changes registes and stack pointer bank.
 THR_RST  TH_ID, START_ADDR ; reset TH_ID thread and set PC to START_ADDR and start thread
 THR_SYCN uniq_id ; 
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
