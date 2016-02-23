# simple SoC

### address

|   addr     | module          | MNEMONIC | comment |
|        ---:|:---             | :--- | :--- |
| **`00_xx`** - **`10_xx`** | RAM with program and data        | | |
| `..00xxx` |  hardware interrupts | | 8 interrupts |
| `..01xxx` | software interrupts | | 8 interrupts |
| `..00000` | *reset* | | |
| `..00001` | *timer_1* | | controlled by $rt |
| **`11_xx_xx_xx_x`** | Registers, IO, stack   | | |
| `11_00_xxx`| | | 2 ^ 28 |
| `..0xxxx`  | User Registers  | $r0-$r15 | | 
| `..10000`  | flag register   | $rf | |
| `..10001`  | timer interapt mask   | $rt | |
| `..10010`  | stack head | $st | |
| `..11001`  | digits on board | | |
| `..11100`  | GPU command     | | |
| `..11101`  | GPU data        | | |
| `11_01_xxx` | Stack | | 2 ^ 28|

### flag register
`
[0] -- carry
[1] -- does result of last operation is zero
`
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
