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

start_main:
    @ Set counter to initial value
    MOVS R5, #0

check_inputs:
    @ Inspect BTN3 state (PA3) for halt
    LDR R6, GPIOA_BASE
    LDR R6, [R6, #0x10]  @ Access GPIOA IDR
    MOVS R7, #8          @ Mask for PA3
    ANDS R7, R6          @ Verify if PA3 is activated
    BEQ pause_leds      @ Jump if PA3 button pressed

    @ Inspect SW2 state (PA2)
    MOVS R7, #4          @ Mask for PA2
    ANDS R7, R6          @ Verify if PA2 is activated
    BEQ set_pattern   @ Jump if PA2 is low (button pressed)

    @ Update LED with current value
    STR R5, [R8, #0x14]

    @ Inspect BTN1 state (PA1) to determine delay length
    MOVS R7, #2          @ Mask for PA1
    ANDS R7, R6          @ Verify if PA1 is activated
    BNE long_delay       @ Jump if PA1 is button not pressed

    @ BTN1 is pressed, use brief delay (0.3 seconds)
    LDR R6, SHORT_DELAY_CNT
    B begin_delay

long_delay:
    @ BTN1 is not pressed, use prolonged delay (0.7 seconds)
    LDR R6, LONG_DELAY_CNT

begin_delay:
delay_counter:
    SUBS R6, #1
    BNE delay_counter

    @ Inspect BTN0 state (PA0)
    LDR R6, GPIOA_BASE
    LDR R6, [R6, #0x10]  @ Access GPIOA IDR
    MOVS R7, #1          @ Mask for PA0
    ANDS R7, R6          @ Verify if PA0 is activated
    BNE add_one          @ Jump if PA0 is high (button not pressed)

    @ BTN0 is pressed, increase by 2
    ADDS R5, #2
    B loop_next

add_one:
    @ BTN0 is not pressed, increase by 1
    ADDS R5, #1

loop_next:
    @ Counter will automatically reset to 0 if it overflows
    B check_inputs

set_pattern:
    @ BTN2 is pressed, set LED pattern to 0xBB
    MOVS R5, #0xAA
    STR R5, [R8, #0x14]  @ Output to LEDs
    B release_btn2

release_btn2:
    @ Check if BTN2 is still pressed
    LDR R6, GPIOA_BASE
    LDR R6, [R6, #0x10]  @ Access GPIOA IDR
    MOVS R7, #4          @ Mask for PA2
    ANDS R7, R6          @ Verify if PA2 is activated
    BEQ release_btn2     @ If BTN2 remains pressed, continue waiting

    @ BTN2 released, resume normal counting from 0xAA
    B check_inputs

pattern_leds:
    @ BTN3 is pressed, pause the pattern
    STR R5, [R8, #0x14]  @ Update LED with current value

release_btn3:
    @ Check if BTN3 is still pressed
    LDR R6, GPIOA_BASE
    LDR R6, [R6, #0x10]  @ Access GPIOA IDR
    MOVS R7, #8          @ Mask for PA3
    ANDS R7, R6          @ Verify if PA3 is activated
    BEQ release_btn3     @ If BTN3 remains pressed, continue waiting

    @ BTN3 released, resume counting from the current value
    B check_inputs

write_current_leds:
    STR R5, [R8, #0x14]
    B start_main


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
