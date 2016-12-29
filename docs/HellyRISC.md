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

| segment |    a               | b     | c                                 | d    |
|     ---:|                ---:| :---  | :---                              | :--- |
| `b00_`  |   h_0_00_x         |       | hardware interrupts vector table  |      |
|         |   h_0_01_x         |       | software interrupts vector table  |      |
|         |   h_0_02_0         |       | user interrupts                   |      |
|         |                    |       |                                   |      |
| `b11_`  |                    |       |                                   |      |
|         | b11_00_00_.._1_x    |       | users register                    |      |
|         | b11_00_00_.._2_x    |       | system registers                  |      |
|         |                    | _0    | status and flag register          |      |
|         |                    | _1    | interrupt timer ....              |      |
|         |                    | _2    | General interrupts mask           |      |
|         |                    | _3    |                                   |      |
|         |                    | _4    |                                   |      |
|         |                    | _6    |                                   |      |
|         |                    | _7    | Link register ($LR)               |      |
|         |                    | _8    | Programm counter ($PC)            |      |
|         |                    | _13   | Multiply HIGH			    |      |
|         |                    | _15   | CPU_ID                            |      |
|         | b11_00_01_..        |       | Devices table                     |      |



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
| 001  | h0B    | ASL		| z, x, y	| Arifmetical shift left	| z = x << y			|
| 001  | h0C    | ASR		| z, x, y	| Arifmetical shift right	| z = x << y			|
| 000  | h01    | BRN		| label	   	| Branch			| $CP = label			|
| 000  | h02    | BRNR		| shift	   	| Branch relative		| $CP = $CP + shift		|
| 000  | h03    | BRL		| label    	| Branch and link		| $LR = $PC; $CP = label	|
| 000  | h04    | BRLR		| shift    	| Branch and link relative	| $LR = $PC; $CP = $CP + shift	|
| 000  | h05    | BRF		| label, x, y	| Branch with fast check	| if (y == x) $CP = label       |
| 000  | h06    | BRLF		| label, x, y	| Branch and link with f. check	| if (y == x) $LR = $CP; $CP = label       |
| 000  | h07-F  | ---		|		| reserver			| 				|
| 001  | h03	| CMP		| x, y		| Compare 			| set flags 			| 
| 000  | h10	| INT		| x		| Software interrupt		| 				|
| 001  | h04    | XOR		| z, x, y	| Exclusive or			| z = x ^ y			|
| 000  | h15	| MOV		| z, x		| Move x to z			| z = x				|
| 001  | h05    | LSLS          | z, x, y	| Logical shift left		| z = x << y			|
| 001  | h06    | LSRS		| z, x, y	| Logical shift right		| z = x >> y			|
| 001  | h07    | MUL		| z, x, y	| Multiply			| {$rmh, z} = x * y		|
| 001  | h08    | NOT		| z, x		| Bitwise NOT			| z = !x			|
| 000  | h00	| NOP		| -		| No Operation			|				|
| 001  | h09    | ORR           | z, x, y       | Bitwise Or			| z = x | y			|
| 000  | h16    | POP		| r		| Pop from stack		| 				|
| 000  | h17    | PUSH		| r		| Push to stack			|				|
| 001  | h0A	| REV		| z, x		| Reverse			| z = 0 - x			|
| 001  | h0D	| SUB		| z, x, y	| Sub				| z = x - y			|
| 000  | h18    | WFI		| -		| Wait for interrupt		| 				|


#### Addressing

##### Direct

Load directly by address

`$r` -- direct to register

`xxxx` -- absolute by RAM address

#### Indirect

Load from address stored in `addr`.

`@r` or `@xxxx`

#### Relative

`PC+shift` -- relative to PC | `b0001_xxxx`

`ST+shift` -- relative to stack | `b0000_xxxx`


#### Relative-indirect

Relative can be combined with indirect. Was be:

Load `[addr]` from `PC|ST + shift `, then load data from `[addr]`

## Devices table


# HellyRISC Async work mode

## brief

### task queue

Task queue store sequence of tasks, which one by one processing by CPU's.

| IP | ST | FR | R1 |
| -: | -: | -: | -: |

Pushing task to queue:

```
BRNC ; make a new brunch (and initialize new stack)
PUSH $ST1 $r1 ; push value to created stack
PUSH $ST1 $ST ; push another 
PUSH $ST1 $PC+2 ; push processing callback function
SNDQ :some_async_func #{$ST1} ; send task to queue
PQ ; change to another task
ADD ; return point from async task
MUL ; take from stack to values and multiply them
MV #1000_0001 ; send some data to some external device
PQ ; change to another task
```