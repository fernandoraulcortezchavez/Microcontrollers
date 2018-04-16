ORG 00H

MOV P3, #0FFH
ACALL SUB_INIT

GAME_START:	MOV 30H, #00H
            MOV 31H, #00H
			MOV A, #01H
			ACALL SUB_COMMANDWRT
			ACALL SUB_DELAY
			LCALL SUB_DISPLAY_POINTS_A
			LCALL SUB_DISPLAY_POINTS_B

LOOP_START: 
            JB P3.0, DELIVER_A
            JB P3.1, DELIVER_B
			SJMP LOOP_START

; ------------- Player A -------------
DELIVER_A:     JB P3.0, DELIVER_A ;The ball will move until the player unpresses the button
			   JMP A_PLAYER_TURN
               
A_PLAYER_TURN:   LCALL SUB_DRAW_PADDLES
                 MOV A, #0C1H
                 ACALL SUB_COMMANDWRT
                 ACALL SUB_DELAY
                 MOV A, #'*'
                 ACALL SUB_DATAWRT
                 ACALL SUB_BIG_DELAY
				 
A_PLAYER_BACK:   MOV R5, #0CH
        SHIFT_R:
				 LCALL SUB_BALL_RIGHT
				 ACALL SUB_BIG_DELAY
				 
LOSS_DELAY1:	MOV R1, #03H
  LOSS_REPEAT1:	JB P3.0, POINT_FOR_B ; Player A pressed before correct time
				JB P3.1, POINT_FOR_A ; Player B pressed before correct time
				ACALL SUB_DELAY
				DJNZ R1, LOSS_REPEAT1
					
	            DJNZ R5, SHIFT_R
				LCALL SUB_BALL_RIGHT
				ACALL SUB_DELAY

DELAY_TURN_B:	MOV R1, #08H
TURN_REPEAT_B:	JB P3.0, POINT_FOR_B ; Player A pressed before correct time
				JB P3.1, B_PLAYER_BACK_TAG; Player B pressed correct time
				ACALL SUB_DELAY
				;DJNZ R0, LOSS_REPEAT_B
				DJNZ R1, TURN_REPEAT_B
				JMP POINT_FOR_A

B_PLAYER_BACK_TAG: LCALL SUB_RIGHT_PADDLE
                   LJMP B_PLAYER_BACK
			   
; ---------------- Player B ----------------
DELIVER_B:     JB P3.0, DELIVER_B ;The ball will move until the player unpresses the button
			   JMP B_PLAYER_TURN


POINT_FOR_A: INC 30H
			 MOV A, #01H
			 ACALL SUB_COMMANDWRT
			 ACALL SUB_DELAY
			 LCALL SUB_DISPLAY_POINTS_A
			 LCALL SUB_DISPLAY_POINTS_B
			 MOV A, 30H
			 CJNE A, #04H, JUMP_TAG ; Check if A won
			 LCALL SUB_A_WON
			 LJMP GAME_START
			          
POINT_FOR_B: INC 31H
			 MOV A, #01H
			 ACALL SUB_COMMANDWRT
			 ACALL SUB_DELAY
			 LCALL SUB_DISPLAY_POINTS_A
			 LCALL SUB_DISPLAY_POINTS_B
			 MOV A, 31H
			 CJNE A, #04H, JUMP_TAG ; Check if B won
			 MOV DPTR, #WON_LBL
			 LCALL SUB_B_WON
			 LJMP GAME_START	

JUMP_TAG: LJMP LOOP_START

;-------------------------------------Player B-----------------------
B_PLAYER_TURN:   LCALL SUB_DRAW_PADDLES
                 MOV A, #0CEH
                 ACALL SUB_COMMANDWRT
                 ACALL SUB_DELAY
                 MOV A, #'*'
                 ACALL SUB_DATAWRT
                 ACALL SUB_BIG_DELAY
				 
B_PLAYER_BACK:   MOV R5, #0CH
        SHIFT_L: 
				 LCALL SUB_BALL_LEFT
				 ACALL SUB_BIG_DELAY
				 
	LOSS_DELAY2: MOV R1, #03H
LOSS_REPEAT2:    JB P3.0, POINT_FOR_B ; Player A pressed before correct time
				 JB P3.1, POINT_FOR_A ; Player B pressed before correct time
				 ACALL SUB_DELAY
				 DJNZ R1, LOSS_REPEAT2
				 
	             DJNZ R5, SHIFT_L
				 LCALL SUB_BALL_LEFT
				 ACALL SUB_DELAY

				 
DELAY_TURN_A:	MOV R1, #08H
TURN_REPEAT_A:	JB P3.0, A_PLAYER_BACK_TAG ; Player A pressed correct time
				JB P3.1, POINT_FOR_A ; Player B pressed before correct time
				ACALL SUB_DELAY
				;DJNZ R0, LOSS_REPEAT_A
				DJNZ R1, TURN_REPEAT_A
				 
				JMP POINT_FOR_B
A_PLAYER_BACK_TAG: LCALL SUB_LEFT_PADDLE
                   LJMP A_PLAYER_BACK

; -------------------- Helper subroutines ----------------------	
/*
** Subroutine that initializes a LCD screen.
*/ 
SUB_INIT:      
               MOV A, #38H ; 2 lines, 7x8 matrix
			   ACALL SUB_COMMANDWRT
			   ACALL SUB_DELAY
			   ;MOV A, #0FH ; Screen on, cursor on
			   MOV A, #0CH ; Screen on, cursor off
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
           MOV R0, #01H
REPEAT:    ;MOV TH0, #3CH
           ;MOV TL0, #0B0H
		   MOV TH0, #0DCH
           MOV TL0, #0B0H
           MOV TMOD, #01H
           SETB TR0
		   LOOP_WAIT: JNB TF0, LOOP_WAIT
		   CLR TR0
		   CLR TF0
		   DJNZ R0, REPEAT
		   RET

SUB_BIG_DELAY: MOV R7, #05H
BIG_REPEAT:    ACALL SUB_DELAY
			   DJNZ R7, BIG_REPEAT
               RET

SUB_BALL_RIGHT: MOV A, #10H
                ACALL SUB_COMMANDWRT
				ACALL SUB_DELAY
				MOV A, #' '
				ACALL SUB_DATAWRT
				ACALL SUB_BIG_DELAY ;To balance the wait time between ball right and ball left
				MOV A, #'*'
				ACALL SUB_DATAWRT
				ACALL SUB_DELAY
				RET

SUB_BALL_LEFT:  MOV A, #10H
                ACALL SUB_COMMANDWRT
				ACALL SUB_DELAY
				MOV A, #' '
				ACALL SUB_DATAWRT
				ACALL SUB_DELAY
				MOV A, #10H
                ACALL SUB_COMMANDWRT
				ACALL SUB_DELAY
				MOV A, #10H
                ACALL SUB_COMMANDWRT
				ACALL SUB_DELAY
				MOV A, #'*'
                ACALL SUB_DATAWRT
				ACALL SUB_DELAY
				RET

/*
**
*/
SUB_DRAW_PADDLES:
                MOV A, #0C0H
				ACALL SUB_COMMANDWRT
				ACALL SUB_DELAY
				MOV A, #'|'
				ACALL SUB_DATAWRT
				ACALL SUB_DELAY
				MOV A, #0CFH
				ACALL SUB_COMMANDWRT
				ACALL SUB_DELAY
				MOV A, #'|'
				ACALL SUB_DATAWRT
				ACALL SUB_DELAY
				RET
				
/*
**
*/
SUB_LEFT_PADDLE:
                MOV A, #0C0H
				ACALL SUB_COMMANDWRT
				ACALL SUB_DELAY
				MOV A, #' '
				ACALL SUB_DATAWRT
				ACALL SUB_DELAY
				MOV A, #'|'
				ACALL SUB_DATAWRT
				ACALL SUB_BIG_DELAY
				ACALL SUB_BIG_DELAY
				ACALL SUB_BIG_DELAY
				MOV A, #0C0H
				ACALL SUB_COMMANDWRT
				ACALL SUB_DELAY
				MOV A, #'|'
				ACALL SUB_DATAWRT
				ACALL SUB_DELAY
				MOV A, #' '
				ACALL SUB_DATAWRT
				ACALL SUB_DELAY
				MOV A, #0C2H
				ACALL SUB_COMMANDWRT
				ACALL SUB_DELAY
				RET
/*
**
*/
SUB_RIGHT_PADDLE:
                MOV A, #0CEH
				ACALL SUB_COMMANDWRT
				ACALL SUB_DELAY
				MOV A, #'|'
				ACALL SUB_DATAWRT
				ACALL SUB_DELAY
				MOV A, #' '
				ACALL SUB_DATAWRT
				ACALL SUB_BIG_DELAY
				ACALL SUB_BIG_DELAY
				ACALL SUB_BIG_DELAY
				MOV A, #0CEH
				ACALL SUB_COMMANDWRT
				ACALL SUB_DELAY
				MOV A, #' '
				ACALL SUB_DATAWRT
				ACALL SUB_DELAY
				MOV A, #'|'
				ACALL SUB_DATAWRT
				ACALL SUB_DELAY
				MOV A, #0CFH
				ACALL SUB_COMMANDWRT
				ACALL SUB_DELAY
				RET

/*
**
*/
SUB_DISPLAY_POINTS_A:
					  MOV A, 30H
                      ACALL SUB_POINTS_TO_MESSAGE
                      
					  MOV A, #80H
					  ACALL SUB_COMMANDWRT
					  ACALL SUB_DELAY
					  ACALL SUB_DISPLAY_STRING
					  RET				
/*
**
*/
SUB_DISPLAY_POINTS_B:
					  MOV A, 31H
                      ACALL SUB_POINTS_TO_MESSAGE
                      CLR A
					  
					  MOV R6, #00H
B_COUNT_NEXT_CHAR:    MOVC A, @A+DPTR
                      JZ B_INITIALIZE_CURSOR
					  INC R6
					  CLR A
					  MOV A, R6 ; OFFSET A to not move DPTR
					  SJMP B_COUNT_NEXT_CHAR

B_INITIALIZE_CURSOR:  MOV A, #90H
                      SUBB A, R6 ;Move the cursor back the appropiate number of spaces before the row end
					  MOV R6, #00H
                      ACALL SUB_COMMANDWRT
					  ACALL SUB_DELAY
					  ACALL SUB_DISPLAY_STRING
					  RET
/*
**
*/
SUB_A_WON:            MOV A, #01H
                      ACALL SUB_COMMANDWRT
					  ACALL SUB_DELAY
					  MOV A, #80H
					  ACALL SUB_COMMANDWRT
					  ACALL SUB_DELAY
                      MOV DPTR, #WON_LBL
					  ACALL SUB_DISPLAY_STRING
					  ACALL SUB_BIG_DELAY
					  ACALL SUB_BIG_DELAY
					  MOV A, #01H
					  ACALL SUB_COMMANDWRT
					  ACALL SUB_DELAY
					  MOV A, #80H
					  ACALL SUB_COMMANDWRT
					  ACALL SUB_DELAY
					  MOV R1, 15
					  FILL:	MOV A, '#'
							ACALL SUB_DATAWRT
							DJNZ R1, FILL
					  ACALL SUB_BIG_DELAY
					  RET

/*
**
*/
SUB_B_WON:            MOV A, #01H
                      ACALL SUB_COMMANDWRT
					  ACALL SUB_DELAY
					  MOV A, #8DH
					  ACALL SUB_COMMANDWRT
					  ACALL SUB_DELAY
                      MOV DPTR, #WON_LBL
					  ACALL SUB_DISPLAY_STRING
					  ACALL SUB_BIG_DELAY
					  ACALL SUB_BIG_DELAY
					  MOV A, #01H
					  ACALL SUB_COMMANDWRT
					  ACALL SUB_DELAY
					  MOV A, #80H
					  ACALL SUB_COMMANDWRT
					  ACALL SUB_DELAY
					  MOV R1, 15
					  FILL:	MOV A, '#'
							ACALL SUB_DATAWRT
							DJNZ R1, FILL
					  ACALL SUB_BIG_DELAY
					  RET
					  

/*
** Displays the string that starts at code memory address pointed by DPTR starting from the current
** LCD position
*/
SUB_DISPLAY_STRING:   CLR A
NEXT_CHAR:            MOVC A, @A+DPTR
                      JZ FINISHED_STRING				  
					  ACALL SUB_DATAWRT
					  ACALL SUB_DELAY
					  CLR A
					  INC DPTR
                      SJMP NEXT_CHAR
FINISHED_STRING:      RET

/*
**
*/
SUB_POINTS_TO_MESSAGE: 
                      CJNE A, #00H, CHECK_ONE
					  MOV DPTR, #CERO_PTS
					  RET					  
CHECK_ONE:            CJNE A, #01, CHECK_TWO
                      MOV DPTR, #ONE_PTS
		              RET					  
CHECK_TWO:            CJNE A, #02, CHECK_THREE
                      MOV DPTR, #TWO_PTS
					  RET					  
CHECK_THREE:          CJNE A, #03, CHECK_FOUR
                      MOV DPTR, #THREE_PTS
					  RET
CHECK_FOUR:           MOV DPTR, #FOUR_PTS
                      RET

;------------------------------------------------------------
ORG 300H
CERO_PTS: DB 'Zero',0
ONE_PTS: DB 'One',0
TWO_PTS: DB 'Two',0
THREE_PTS: DB 'Three',0
FOUR_PTS: DB 'Four',0
WON_LBL: DB 'Winner',0
			

		 		   
END
