ORG 00H

MOV P3, #0FFH
ACALL SUB_INIT



MSB_PLAYER_TURN: MOV A, #0C2H
                 ACALL SUB_COMMANDWRT
                 ACALL SUB_DELAY
                 MOV A, #'*'
                 ACALL SUB_DATAWRT
                 ACALL SUB_DELAY
MSB_PLAYER_BACK: MOV R5, #0DH
        SHIFT_R: MOV A, #1CH
                 ACALL SUB_COMMANDWRT
                 ACALL SUB_DELAY
	             DJNZ R5, SHIFT_R
				 SJMP LSB_PLAYER_BACK

LSB_PLAYER_TURN: MOV A, #0CFH
                 ACALL SUB_COMMANDWRT
                 ACALL SUB_DELAY
                 MOV A, #'*'
                 ACALL SUB_DATAWRT
                 ACALL SUB_DELAY
LSB_PLAYER_BACK: MOV R5, #0DH
        SHIFT_L: MOV A, #18H
                 ACALL SUB_COMMANDWRT
                 ACALL SUB_DELAY
	             DJNZ R5, SHIFT_L
				 SJMP MSB_PLAYER_BACK

	  


	
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
