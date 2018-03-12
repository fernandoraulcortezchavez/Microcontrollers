ORG 00H
	
; -------------------- Helper subroutines ----------------------	
/*
** Subroutine that initializes a LCD screen.
*/ 
SUB_INIT:      
               MOV A, #38H ; 2 lines, 7x8 matrix
			   ACALL SUB_COMMANDWRT
			   ACALL SUB_DELAY
			   MOV A, #0EH ; Screen on, cursor on
			   ACALL SUB_COMMANDWRT
			   ACALL SUB_DELAY
			   MOV A, #01AH ; Clear screen
			   ACALL SUB_COMMANDWRT
			   ACALL SUB_DELAY
			   MOV A, #81H ; Shift cursor right
			   ACALL SUB_COMMANDWRT
			   ACALL SUB_DELAY
			   RET
		
/*
** Subroutine that writes the command at A to the LCD screen.
*/ 
SUB_COMMANDWRT: 
               MOV P1, A
               CLR P2.0        ; Rs = 0 Command
			   CLR P2.1        ; R/W' = 0 Write
			   SETB P2.2
			   ACALL SUB_DELAY
			   CLR P2.2
			   RET

/*
** Subroutine that writes the data at A to the LCD screen.
*/ 
SUB_DATAWRT:   
               MOV P1, A
			   SETB P2.0         ; Rs = 1 Data
			   CLR P2.1          ; R/W' = 0 Write
			   SETB P2.2
			   ACALL SUB_DELAY
			   CLR P2.2
			   RET
/*
** Subroutine that generates a 250 ms delay, generally used between LCD operations.
*/ 			   
SUB_DELAY: 
           MOV R0, #05H
REPEAT:    MOV TH0, #3CH
           MOV TL0, #0B0H
           MOV TMOD, #01H
           SETB TR0
		   LOOP_WAIT: JNB TF0, LOOP_WAIT
		   CLR TR0
		   CLR TF0
		   DJNZ R0, REPEAT
		   RET
		   
END
