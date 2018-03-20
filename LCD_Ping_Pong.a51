ORG 00H

MOV P3, #0FFH
ACALL SUB_INIT

GAME_START:	MOV 30H, #00H
            MOV 31H, #00H

LOOP_START: 
            JB P3.0, DELIVER_A
            JB P3.1, DELIVER_B
			SJMP LOOP_START

; ------------- Player A -------------
DELIVER_A:     JB P3.0, DELIVER_A ;The ball will move until the player unpresses the button
			   JMP A_PLAYER_TURN
               
						  
			   
; ---------------- Player B ----------------
DELIVER_B:     JB P3.0, DELIVER_B ;The ball will move until the player unpresses the button
			   JMP B_PLAYER_TURN

A_PLAYER_TURN: MOV A, #0C2H
                 ACALL SUB_COMMANDWRT
                 ACALL SUB_DELAY
                 MOV A, #'*'
                 ACALL SUB_DATAWRT
                 ACALL SUB_DELAY
				 
A_PLAYER_BACK: MOV R5, #0DH
        SHIFT_R: MOV A, #1CH
                 ACALL SUB_COMMANDWRT
				 ACALL SUB_LOSS_DELAY
	             DJNZ R5, SHIFT_R
 				 ACALL DELAY_TURN_B
				 JMP POINT_FOR_A

B_PLAYER_TURN: MOV A, #0CFH
                 ACALL SUB_COMMANDWRT
                 ACALL SUB_DELAY
                 MOV A, #'*'
                 ACALL SUB_DATAWRT
                 ACALL SUB_DELAY
B_PLAYER_BACK: MOV R5, #0DH
        SHIFT_L: MOV A, #18H
                 ACALL SUB_COMMANDWRT
				 ACALL SUB_LOSS_DELAY
	             DJNZ R5, SHIFT_L
				 ACALL DELAY_TURN_A
				 JMP POINT_FOR_B

	  


	
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
/*
** Subroutine that checks if any player pressed in between turns.
*/ 		   
SUB_LOSS_DELAY:	MOV R0, #5
   LOSS_REPEAT:	JB P3.0, POINT_FOR_B ; Player A pressed before correct time
				JB P3.1, POINT_FOR_A ; Player B pressed before correct time
				ACALL SUB_DELAY
				DJNZ R0, LOSS_REPEAT
				RET
/*
** Subroutine that checks for player presses at their turns.
*/ 
DELAY_TURN_A:	MOV R0, #5
TURN_REPEAT_A:	JB P3.0, A_PLAYER_BACK ; Player A pressed correct time
				JB P3.1, POINT_FOR_A ; Player B pressed before correct time
				ACALL SUB_DELAY
				DJNZ R0, LOSS_REPEAT_A
				RET
				
DELAY_TURN_B:	MOV R0, #5
TURN_REPEAT_B:	JB P3.0, POINT_FOR_B ; Player A pressed before correct time
				JB P3.1, B_PLAYER_BACK; Player B pressed correct time
				ACALL SUB_DELAY
				DJNZ R0, LOSS_REPEAT_B
				RET
			
POINT_FOR_A: INC 30H
			 ACALL SUB_SHOW_POINTS
			 MOV A, 30H
			 CJNE A, #04H, LOOP_START
			 ;Todo Display score
			 SJMP GAME_START
			          
POINT_FOR_B: INC 31H
			 ACALL SUB_SHOW_POINTS
			 MOV A, 31H
			 CJNE A, #04H, LOOP_START
			 ;TODO Display score
			 SJMP GAME_START			
		 		   
END
