# HellyRISC architecture overview

## Naming convention

`HR-{mjv}{mnv}-{cpu}|{gpu}-{pak}__{additional}`

`{mjv}` -- major arch version

`{mnv}` -- minor arch version

`{cpu}` -- cpu's: [count.edition.frnq], where count -- 4-char count of CPU's, edition -- CPU editions (I - integer, F - extended with floating, ...), frnq -- CPU frenquency

`{gpu}` -- GPU unit, Z -- zero (non-gpu), T -- text only

`{pak}` -- package: D - DIP package, S -- SMD

`{additional}`: some other information



## Memory map

| segment |    a        | b     | c                                 | d    |
|     ---:|         ---:| :---  | :---                              | :--- |
| `h00_`  |   h_0_00_x  |       | hardware interrupts vector table  |      |
|         |   h_0_01_x  |       | software interrupts vector table  |      |
|         |   h_0_02_0  |       | user interrupts                   |      |
|         |             |       |                                   |      |
| `h11_`  |             |       |                                   |      |
|         | h_0_01_x    |       | users register                    |      |
|         | h_0_02_x    |       | system registers                  |      |
|         |             | _0    | status and flag register          |      |
|         |             | _1    | interrupt timer ....              |      |
|         |             | _2    | General interrupts mask           |      |
|         |             | _3    |                                   |      |
|         |             | _4    |                                   |      |
|         |             | _6    |                                   |      |
|         |             | _7    | Link register ($LR)               |      |
|         |             | _8    | Programm counter ($PC)            |      |
|         |             | _15   | CPU_ID                            |      |
|         | h_1_1x_x    |       | GPU commutation space             |      |
|         | h_1_2x_x    |       |                                   |      |



## Registers

#### status and flag register

| bit | postfix | desc       |
| :--- | :---   | :---       |
| 0    |  _c    |  carry     |
| 1    |  _z    |  zerro     | 
| 2    |  _e    | equal      |
| 3    |  _m    | overflow   |
| 4    |  _g    | grate that |
| 5    |  _n    | negative   |
|      |        |            |
| 30-31|        | thread_id  |


#### Interrupt timer mask

Timer was sets to [interrupt timer mask] and every tick decreases by 1. When counter was be a zero -- timer interrupt was thrown, counter sets to [interrupt timer mask] again.

#### General interrupts mask

Allow (1) or dissalow (0) hardware and software interrupts.



## Instructions

```
instruction | 32bit | 00
operand Z   | 32bit | 01
operand X   | 32bit | 02
operand Y   | 32bit | 03
```

Instruction struct:

| bit(s) | desc |
|  ---:  | :--- |
| 31     |      |
| 30     |      |
| 29     |      |
| 28-26  | operation mode (000 -- flow, 001 -- arifmetic) |
| 25-18  | OPCODE |
| ...    |      |
| 15-9   | postfix's |
| ...    |      |
| 6      | z: 0 - absolute, 1 - relative |
| 5      | x: 0 - absolute, 1 - relative |
| 4      | y: 0 - absolute, 1 - relative |
| 3      | z: 0 - direct, 1 - indirect |
| 2      | x: 0 - direct, 1 - indirect |
| 1      | y: 0 - direct, 1 - indirect |
| 0      |      |


#### Instruction set

| mode | OPCODE | Mnemonic 	| Operands 	| Brief description 		| Operations  			|
| ---: |   ---: | :---     	| :---     	| :---              		| :---				|
| 001  | h01    | ADD         	| z, x, y  	| Add               		| z = x + y			|
| 001  | h02    | AND	 	| z, x, y  	| Bitwise AND			| z = x & y			|
| 000  | h01    | BRN		| label	   	| Branch			| $CP = label			|
| 000  | h02    | BRNR		| shift	   	| Branch relative		| $CP = $CP + shift		|
| 000  | h03    | BRL		| label    	| Branch and link		| $LR = $PC; $CP = label	|
| 000  | h04    | BRLR		| shift    	| Branch and link relative	| $LR = $PC; $CP = $CP + shift	|
| 000  | h05    | BRF		| label, x, y	| Branch with fast check	| if (y == x) $CP = label       |
| 000  | h06    | BRLF		| label, x, y	| Branch and link with f. check	| if (y == x) $LR = $CP; $CP = label       |
