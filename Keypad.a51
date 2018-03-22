ORG 00H
	MOV P1, #0FFH	;P1 is input for columns
	
LOOP:	MOV P2, #0H	;P2 is output for rows
		MOV A, P1
		ANL 00001111B
		CJNE A, #00001111B, CHECK
		
		JMP LOOP


CHECK:					;KEY PRESSED, WAIT FOR DEBOUNCE
		ACALL SUB_DELAY ;DEBOUNCE TIME
		MOV A, P2
		ANL A, 00001111B
		CJNE A, 00001111B, CHECKROW	;REAL KEY PRESS
		JMP LOOP ; IF NO KEY PRESSED, GO BACK
		
CHECKROW:
		MOV P1, #11111110B ;GROUND 0
		MOV A, P2
		ANL A, #00001111B
		CJNE A,#00001111B, ROW_0
		MOV P1, #11111101B	;GROUND 1
		MOV A, P2
		ANL A, #00001111B
		CJNE A,#00001111B, ROW_1
		MOV P1, #11111011B	;GROUND 2
		MOV A, P2
		ANL A, #00001111B
		CJNE A,#00001111B, ROW_2
		MOV P1, #11110111B	;GROUND 3
		MOV A, P2
		ANL A, #00001111B
		CJNE A,#00001111B, ROW_3
		JMP LOOP	;FALSE INPUT, REPEAT
		
		
/*
Uses timer to make a 20ms delay
*/
SUB_DELAY: MOV TH0, #0B1H
           MOV TL0, #0E0H
           MOV TMOD, #01H
           SETB TR0
		   LOOP_WAIT:	JNB TF0, LOOP_WAIT
						CLR TR0
						CLR TF0
		   RET