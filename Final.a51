RS          EQU         P1.0  ; Register Select: Selects command register when low and data register when high
RW          EQU         P1.1  ; Read / Write: low to write and high to read
E           EQU         P1.2  ; Enable: sends data to data pins when high to low pulse is given
DATA_PORT   EQU         P0    ; Define input port


ORG 0000H
MOV TMOD, #20H // Timer 1configured in Mode 2
MOV TH1, #0FDH // set 9600 bps baud rate
MOV SCON, #50H // 8-bit data, 1 stop bit, REN enabled
SETB TR1 // start Timer 1 to generate clock (at baud rate)
MOV R0, #40H 
MOV P2, #0FFH // configure P2 as input for reading data
LCALL WAIT // initialization of LCD by software
LCALL WAIT // this part of program is not mandatory but
MOV A, #38H // recommended to use because it will
LCALL COMMAND // guarantee proper initialization even when
LCALL WAIT // power supply reset timings are not met
MOV A, #38H
LCALL COMMAND
LCALL WAIT
MOV A, #38H
LCALL COMMAND // initialization complete
MOV A, #38H // initialize LCD, 8-bit interface, 5X7 dots/character
LCALL COMMAND // send command to LCD
MOV A, #0FH // display on, cursor on with blinking
LCALL COMMAND // send command to LCD
MOV A, #06 // shift cursor right
LCALL COMMAND // send command to LCD
MOV A, #01H // clear LCD screen and memory

LCALL COMMAND // send command to LCD
MOV A, #80H // set cursor at line 1, first position
LCALL COMMAND // send command to LCD 

HERE:
	MOV P2, #0FFH
	MOV A, P2 // read data from ADC
	MOV @R0, A // store the sample at 40H onwards
	LCALL DELAY // delay of 1 second
	MAIN:
	CJNE @R0, #0FFH, APAGAR
	SETB P3.7
	MOV A,#01H
	LCALL COMMAND
	MOV A, #80H // set cursor at line 1, first position
	LCALL COMMAND // send command to LCD 
			MOV A, #'P' // H to be displayed
		LCALL DISPLAY // send data to LCD for display
				MOV A, #'R' // H to be displayed
		LCALL DISPLAY // send data to LCD for display
				MOV A, #'E' // H to be displayed
		LCALL DISPLAY // send data to LCD for display
				MOV A, #'N' // H to be displayed
		LCALL DISPLAY // send data to LCD for display
				MOV A, #'D' // H to be displayed
		LCALL DISPLAY // send data to LCD for display
				MOV A, #'I' // H to be displayed
		LCALL DISPLAY // send data to LCD for display
				MOV A, #'D' // H to be displayed
		LCALL DISPLAY // send data to LCD for display
				MOV A, #'O' // H to be displayed
		LCALL DISPLAY // send data to LCD for display
				MOV A, #"O" // load “H” into A, and call subroutine that will
				ACALL SEND // transmit the character
				MOV A, #"N" // send “A”
				ACALL SEND
				MOV A, #" " // send “A”
				ACALL SEND
	JMP HERE
	//JB P3.6, APAGAR Changed to CJNE
	APAGAR:
	MOV A,#01H
			LCALL COMMAND
			MOV A, #80H // set cursor at line 1, first position
			LCALL COMMAND // send command to LCD 
			MOV A, #'A' // H to be displayed
			LCALL DISPLAY // send data to LCD for display
				MOV A, #'P' // H to be displayed
			LCALL DISPLAY // send data to LCD for display
				MOV A, #'A' // H to be displayed
			LCALL DISPLAY // send data to LCD for display
				MOV A, #'G' // H to be displayed
			LCALL DISPLAY // send data to LCD for display
				MOV A, #'A' // H to be displayed
			LCALL DISPLAY // send data to LCD for display
				MOV A, #'D' // H to be displayed
			LCALL DISPLAY // send data to LCD for display
				MOV A, #'O' // H to be displayed
			LCALL DISPLAY // send data to LCD for display
					MOV A, #"O" // load “H” into A, and call subroutine that will
					ACALL SEND // transmit the character
					MOV A, #"F" // send “A”
					ACALL SEND
					MOV A, #"F" // send “A”
					ACALL SEND
									MOV A, #" " // send “A”
				ACALL SEND
	CLR P3.7
	LCALL WAIT
	JMP HERE

SEND: MOV SBUF, A // serial data transfer subroutine
HERE2: JNB TI, HERE2 // wait until the last bit is sent
CLR TI // clear TI before sending the next byte
RET

COMMAND: // command write subroutine
MOV P0, A // place command on P1
CLR P1.0 // RS = 0 for command
CLR P1.1 // R/W = 0 for write operation
SETB P1.2 // E = 1 for high pulse
LCALL WAIT // wait for some time
CLR P1.2 // E = 0 for H-to-L pulse
LCALL WAIT // wait for LCD to complete the given command
RET
DELAY:  MOV R5, #10 // delay for 1s (Xtal = 12 MHz)
	THR3: MOV R6, #100
	THR2: MOV R7, #250
	THR1: NOP
	NOP
	DJNZ R7, THR1
	DJNZ R6, THR2
	DJNZ R5, THR3
	RET
DISPLAY: // data write subroutine
MOV P0, A // send data to port 1
SETB P1.0 // RS = 1 for data
CLR P1.1 // R/W = 0 for write operation
SETB P1.2 // E = 1 for high pulse
LCALL WAIT // wait for some time
CLR P1.2 // E = 0 for H-to-L pulse
LCALL WAIT // wait for LCD to write the given data
RET
WAIT: MOV R6, #30H // delay subroutine
THERE:  MOV R5, #0FFH //
HERE1:  DJNZ R5, HERE1 //
DJNZ R6, THERE
RET
END
