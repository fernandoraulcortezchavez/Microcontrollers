ORG 00H
MOV P2, #0FFH	;P2 is input for rows
SETB P3.4 ; Will be used as the external interrupt of the other microcontroller

LOOP:	MOV P1, #00H	;P1 is OUTPUT for columns
		MOV A, P2
		ANL A, #00001111B
		CJNE A, #00001111B, CHECK
		JMP LOOP

CHECK:	;KEY PRESSED, WAIT FOR DEBOUNCE
		ACALL SUB_DELAY ;DEBOUNCE TIME
		MOV A, P2
		ANL A, #00001111B
		CJNE A, #00001111B, CHECKROW	;REAL KEY PRESS
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

;--------------------FIND COLUMN-------------------------
ROW_0:  MOV DPTR, #KCODE0
        SJMP FIND
ROW_1:  MOV DPTR, #KCODE1
        SJMP FIND
ROW_2:  MOV DPTR, #KCODE2
        SJMP FIND
ROW_3:  MOV DPTR, #KCODE3

FIND:   RRC A
        JNC MATCH
		INC DPTR
		SJMP FIND
MATCH:  CLR A
        MOVC A, @A+DPTR
		MOV P3, A
		CLR P3.4
		ACALL SUB_DELAY
		SETB P3.4
		LJMP LOOP

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

;------------HEX VALUE LOOK-UP TABLE FOR EACH ROW------------
ORG 300H
KCODE0: DB 00H, 01H, 02H, 03H ;ROW 0
KCODE1:	DB 04H, 05H, 06H, 07H ;ROW 1
KCODE2: DB 08H, 09H, 0AH, 0BH ;ROW 2
KCODE3: DB 0CH, 0DH, 0EH, 0FH ;ROW 0
;--------------------------------------------------------

END
