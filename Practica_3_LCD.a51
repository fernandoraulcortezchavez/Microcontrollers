ORG 00H
	; P1 to LCD
	; P2.0 is Rs
	; P2.1 is R/W'
	; P2.2 is E
	WORD_POS EQU 30H
; -------------------- Main Code -------------------------------
MAIN:          
			   ACALL SUB_INIT
               ACALL SUB_DELAY
			   
			   ; Exercise 1
			   ;ACALL SUB_WRT_ONCE
               
			   ; Exercise 2
			   ;ACALL SUB_RECURSIVE_STR
			   
			   ; Exercise 3
			   ACALL SUB_ORDER
			   ACALL SUB_DISPLAY_LIST
			   
			   HERE:  
		       ACALL SUB_DELAY
			   SJMP HERE
			   
; -------------------- Main subroutines ------------------------
SUB_STRWRT: 
			MOV R1, #10H
REPEAT_STR: CLR A
            MOVC A, @A+DPTR
			ACALL SUB_DATAWRT
			ACALL SUB_DELAY
			INC DPTR
			DJNZ R1, REPEAT_STR 
		    RET

SUB_RECURSIVE_STR: 
WRITE_AGAIN:       MOV A, #81H ;Move cursor to line 1, position 1
                   ACALL SUB_COMMANDWRT
				   ACALL SUB_DELAY
				   MOV DPTR, #FRENCH_STR
				   ACALL SUB_STRWRT
				   SJMP WRITE_AGAIN
				   RET ; Will never be reached 
				   

FRENCH_STR: DB "Bonjour, a tous!",0

SUB_WRT_ONCE:  MOV A, #'H'
			   ACALL SUB_DATAWRT
			   ACALL SUB_DELAY
			   MOV A, #'E'
			   ACALL SUB_DATAWRT
			   ACALL SUB_DELAY
			   MOV A, #'L'
			   ACALL SUB_DATAWRT
			   ACALL SUB_DELAY
			   MOV A, #'L'
			   ACALL SUB_DATAWRT
			   ACALL SUB_DELAY
			   MOV A, #'O'
			   ACALL SUB_DATAWRT
			   ACALL SUB_DELAY
			   MOV A, #','
			   ACALL SUB_DATAWRT
			   ACALL SUB_DELAY
			   
			   MOV A, #' '
			   ACALL SUB_DATAWRT
			   ACALL SUB_DELAY
			   MOV A, #'W'
			   ACALL SUB_DATAWRT
			   ACALL SUB_DELAY
			   MOV A, #'O'
			   ACALL SUB_DATAWRT
			   ACALL SUB_DELAY
			   MOV A, #'R'
			   ACALL SUB_DATAWRT
			   ACALL SUB_DELAY
			   MOV A, #'L'
			   ACALL SUB_DATAWRT
			   ACALL SUB_DELAY
			   MOV A, #'D'
			   ACALL SUB_DATAWRT
			   ACALL SUB_DELAY
			   MOV A, #'!'
			   ACALL SUB_DATAWRT
			   ACALL SUB_DELAY
			   
			   RET
			   
SUB_ORDER: 
           LOOP_SIZE EQU 9
	       MOV 30H, #10H
		   MOV 31H, #08H
	   	   MOV 32H, #5AH
		   MOV 33H, #24H
	       MOV 34H, #54H
		   MOV 35H, #0FFH
		   MOV 36H, #79H
		   MOV 37H, #98H
		   MOV 38H, #38H
		   MOV 39H, #11H
	
           ; First address of the array of numbers	
		   MOV R0, #30H
		   MOV R1, #31H
	
	       ; Size of each loop
	       MOV R2, #LOOP_SIZE
	       MOV R3, #LOOP_SIZE
	
	       ; Bubble sort
	       CHECK: MOV A, @R0
	              SUBB A, @R1 
                  JNC XCHNG
		   
           ; Add by one the R0 and R1 pointers
           NEXT:  INC R0
	              INC R1
		          DJNZ R2, CHECK
		   
		   ; The inner loop finished: reload the inner loop and start again
		   MOV R2, #LOOP_SIZE
		   MOV R0, #30H
		   MOV R1, #31H
		   DJNZ R3, CHECK
           
		   RET

    XCHNG: CLR C
           MOV A, @R1
           XCH A, @R0
           XCH A, @R1
           SJMP NEXT
		   
/*
** Subroutine that takes in a number in two-digit hexadecimal format and displays it on a LCD screen
*/
SUB_DISPLAY_NUM: 
                 MOV B, #10H ; Set B to 16H
                 DIV AB ; Divide Acc by 16H, A will store the first digit and B the second digit of the Acc
				 ; 37H
				 CJNE A, #0AH, CHECK1
CHECK1:          JC NUM1 ;Check if the number in A is lesser than 10 or 0AH
LETTER1:         ADD A, #37H ; Add 37H to make the digit in A to the hex of its Ascii character as a letter
                 SJMP DISP1
NUM1:		     ADD A, #30H ; Add 30H to make the digit in A to the hex of its Ascii character as a number
DISP1:		     ACALL SUB_DATAWRT
				 ACALL SUB_DELAY
				 
				 MOV A, B
				 CJNE A, #0AH, CHECK2
CHECK2:          JC NUM2 ;Check if the number in A is lesser than 10 or 0AH
LETTER2:         ADD A, #37H ; Add 37H to make the digit in A to the hex of its Ascii character as a letter
                 SJMP DISP2
NUM2:		     ADD A, #30H ; Add 30H to make the digit in A to the hex of its Ascii character as a number
DISP2:		     ACALL SUB_DATAWRT
				 ACALL SUB_DELAY				 
				 
				 MOV A, #' '
				 ACALL SUB_DATAWRT
				 ACALL SUB_DELAY
				 RET

/*
** Display on a LCD the numbers stored in D:30H through D:39H
*/
SUB_DISPLAY_LIST: 
                 MOV R3, #05H ; Max number of integers per line, if each one is two digits + ' '
                 MOV R2, #0AH ; Number of integers to be displayed
				 MOV R1, #30H ; Pointer to the first number of the number list
				 MOV A, #81H ;Move cursor to line 1, position 1
                 ACALL SUB_COMMANDWRT
				 ACALL SUB_DELAY
DISPLAY_NEXT:    MOV A, @R1
                 ACALL SUB_DISPLAY_NUM
				 INC R1
				 DJNZ R3, NEXT_CHAR
NEXT_LINE:       MOV R3, #05H
                 MOV A, #0C1H
                 ACALL SUB_COMMANDWRT
				 ACALL SUB_DELAY
NEXT_CHAR:		 DJNZ R2, DISPLAY_NEXT
				 RET


				 
                  
				 
; -------------------- Helper subroutines ----------------------	
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
			   ;MOV A, #84H ; Move cursor to line 1, position 3
			   ;ACALL SUB_COMMANDWRT
			   ;ACALL SUB_DELAY
			   RET
		
 
SUB_COMMANDWRT: 
               MOV P1, A
               CLR P2.0        ; Rs = 0 Command
			   CLR P2.1        ; R/W' = 0 Write
			   SETB P2.2
			   ACALL SUB_DELAY
			   CLR P2.2
			   RET

SUB_DATAWRT:   
               MOV P1, A
			   SETB P2.0         ; Rs = 1 Data
			   CLR P2.1          ; R/W' = 0 Write
			   SETB P2.2
			   ACALL SUB_DELAY
			   CLR P2.2
			   RET
			   
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
