# simple SoC
[![Build status](https://api.travis-ci.org/Corey-Maler/simple_SoC.svg)](https://travis-ci.org/Corey-Maler/simple_SoC)

## SoC architecture overview

![SoC architecture](https://rawgithub.com/Corey-Maler/simple_SoC/master/docs/soc.svg)


Read [HellyRISC architecture overview](https://github.com/Corey-Maler/simple_SoC/blob/master/docs/HellyRISC.md)

### Booting process
1. Bootloader load to RAM basic input/output system, which provide some interrupts and containts programs to display strings, run programs and other.
2. Bootloader copy to memory code from SD-card
3. CPU-enabled flag it turn-on and calling RESET interrupt.


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
