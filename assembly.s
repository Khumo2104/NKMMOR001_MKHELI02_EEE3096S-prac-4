/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns

main_loop:
	@initialize default timing
	LDR R6, LONG_DELAY_CNT
	LDR R0, GPIOA_BASE

	@read input state from IO port
	LDR R1, [R0, #0x10]

	@evaluate button1 status
	MOVS R3, #0x01
	ANDS R3, R1
	BEQ double_shift

	@evaluate button2 status
	MOVS R3, #0x02
	ANDS R3, R1
	BEQ modify_timing

	@evaluate button3 status
	MOVS R3, #0x04
	ANDS R3, R1
	BEQ set_alternate_pattern

	@evaluate button4 status
	MOVS R3, #0x08
	ANDS R3, R1
	BEQ pause_execution

	B standard_operation

double_shift:
	LSRS R2, R2, #2
	CMP R2, #0
	BNE update_output
	@ If pattern exhausted, reset to initial state
	MOVS R2, #0x80
	B update_output

modify_timing:
	LDR R6, SHORT_DELAY_CNT
	B standard_operation

set_alternate_pattern:
	MOVS R2, #0xAA
	B update_output

pause_execution:
	LDR R1, [R0, #0x10]
	MOVS R3, #0x08
	ANDS R3, R1
	BEQ pause_execution
	B main_loop

standard_operation:
	LSRS R2, R2, #1
	CMP R2, #0
	BNE update_output
	MOVS R2, #0x80
	@ If pattern exhausted, reset to initial state

update_output:
	LDR R1, GPIOB_BASE
	STR R2, [R1, #0x14]

wait_cycle:
	SUBS R6, #1
	BNE wait_cycle
	B main_loop


@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
@ Updated delay values (for 48 MHz clock)
LONG_DELAY_CNT: 	.word 1400000  @ 0.7 seconds
SHORT_DELAY_CNT: 	.word 600000  @ 0.3 seconds
