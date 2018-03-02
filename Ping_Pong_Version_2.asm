; Modificaciones:
; Si la pelota no está en tu portería, es punto para el otro jugador
; Sub rutina de flasheo para indicar puntuación cuatro leds máximo por jugador
; Si alguien gana cuatro puntos, todos los leds deben flashear y se reinicia el juego
; El saque debe ser manual, el que pique primero es el que saca
; Usar timers envés de delays
ORG 00H
;START:
;MOV R0, #14H

;MAIN:
;MOV TH0, #3CH
;MOV TL0, #0B0H
;MOV TMOD, #01H
;SETB TR0

;WAIT: JNB TF0, WAIT
;      CLR TR0
;	  CLR TF0
;	  DJNZ R0, MAIN
	  
;	  CPL P2.0
;	  SJMP START

MOV P1, #00H
MOV P3, #0FFH

GAME_START: MOV 30H, #00H
            MOV 31H, #00H
LOOP_START: 
            JB P3.0, PLAYER_A_SET
            JB P3.1, PLAYER_B_SET
			SJMP LOOP_START

; ------------- Player A -------------
PLAYER_A_SET:  MOV A, #10000000b
               MOV P1, A
DELIVER_A:     JB P3.0, DELIVER_A ;The ball will move until the player unpresses the button
               
TURN_A:        MOV R0, #06H ;Number of steps the ball will do
               ACALL SUB_LONG_DELAY ; Required to give the other player some time to unpress his button
LOOP_CONT_A:   RR A
               MOV P1, A
			   
BUTTON_CHECK_NO_GOAL_A:   MOV R1, #05H
LOOP_RECHARGE_TIMER_A:    JB P3.0, POINT_FOR_B ; Player A pressed before correct time
			              JB P3.1, POINT_FOR_A ; Player B pressed before correct time
			              ACALL SUB_DELAY
			              DJNZ R1, LOOP_RECHARGE_TIMER_A
						  
			   DJNZ R0, LOOP_CONT_A  ; Rotate until the boal reaches the goal
			   RR A
			   MOV P1, A
			   
			              ;Check for goal
BUTTON_CHECK_POINT_A:     MOV R1, #05H
LOOP_RECHARGE_TMR_PNT_A:  JB P3.0, POINT_FOR_B ; Player A pressed in time, so switch to player B
			              JB P3.1, TURN_B ; Player B pressed before correct time
			              ACALL SUB_DELAY
			              DJNZ R1, LOOP_RECHARGE_TMR_PNT_A
						  MOV P1, #00H ; Player A wasn't fast enough
						  SJMP POINT_FOR_A
						  
			   
; ---------------- Player B ----------------
PLAYER_B_SET:  MOV A, #00000001b
               MOV P1, A
DELIVER_B:     JB P3.1, DELIVER_b ;The ball will move until the player unpresses the button
               
TURN_B:        MOV R0, #06H ;Number of steps the ball will do
               ACALL SUB_LONG_DELAY ; Required to give the other player some time to unpress his button
LOOP_CONT_B:   RL A
               MOV P1, A
			   
BUTTON_CHECK_NO_GOAL_B:   MOV R1, #05H
LOOP_RECHARGE_TIMER_B:    JB P3.0, POINT_FOR_B ; Player A pressed before correct time
			              JB P3.1, POINT_FOR_A ; Player B pressed before correct time
			              ACALL SUB_DELAY
			              DJNZ R1, LOOP_RECHARGE_TIMER_B
						  
			   DJNZ R0, LOOP_CONT_B  ; Rotate until the ball reaches the goal
			   RL A
			   MOV P1, A
			   
			              ;Check for goal
BUTTON_CHECK_POINT_B:     MOV R1, #05H
LOOP_RECHARGE_TMR_PNT_B:  JB P3.0, TURN_A ; Player A pressed before correct time
			              JB P3.1, POINT_FOR_A ; Player B pressed in time, switch to player A
			              ACALL SUB_DELAY
			              DJNZ R1, LOOP_RECHARGE_TMR_PNT_B
						  MOV P2, #00H ; Player B wasn't fast enough
						  SJMP POINT_FOR_B 


; ---------------- Generic subroutines and blocks -------------
POINT_FOR_A: INC 30H
             ; Add a point to A and check when he gets to four
			 ACALL SUB_SHOW_POINTS
			 MOV A, 30H
			 CJNE A, #04H, LOOP_START
			 SJMP GAME_ENDED
			          
POINT_FOR_B: INC 31H
			 ACALL SUB_SHOW_POINTS
			 MOV A, 31H
			 CJNE A, #04H, LOOP_START
			 SJMP GAME_ENDED
			 

GAME_ENDED: ACALL SUB_FLASHING
            LJMP GAME_START
            
/*
 * Subroutine that shows the points of A and B as a split bar graph on port 1 for some time
 */
SUB_SHOW_POINTS:   MOV A, 30H
                   ADD A, 31H ; Total number of LEDs that will turn on
				   MOV R3, A
				   CLR A
LOOP_INSERT_POINT: SETB C
                   RLC A ; Insert a bit into A
				   CLR C
				   DJNZ R3, LOOP_INSERT_POINT
				   MOV R3, 30H
LOOP_READJUST_PNS: RR A
                   DJNZ R3, LOOP_READJUST_PNS
				   MOV P1, A
				   ACALL SUB_LONG_DELAY
				   ACALL SUB_LONG_DELAY
				   MOV P1, #00H
				   RET

/*
 * Subroutine that sets the timer to count 50us and stops it when overflows
 */
SUB_DELAY: MOV TH0, #3CH
           MOV TL0, #0B0H
           MOV TMOD, #01H
           SETB TR0
		   LOOP_WAIT: JNB TF0, LOOP_WAIT
		   CLR TR0
		   CLR TF0
		   RET

/*
 * Subroutine that makes a 1s delay, using SUB_DELAY some number of times
 */ 
 ;#14h
SUB_LONG_DELAY:	MOV R1, #08H
HERE:           ACALL SUB_DELAY
			    DJNZ R1, HERE
                RET


SUB_HALF_LONG_DELAY: MOV R1, #05H
HALF_HERE:           ACALL SUB_DELAY
			         DJNZ R1, HERE
                     RET 				

SUB_FLASHING: MOV P1, #0FFH
              ACALL SUB_HALF_LONG_DELAY
			  MOV P1, #00H
			  ACALL SUB_HALF_LONG_DELAY
			  MOV P1, #0FFH
			  ACALL SUB_HALF_LONG_DELAY
			  MOV P1, #00H
			  RET
						  
END
