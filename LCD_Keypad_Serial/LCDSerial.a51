EXTRN CODE (SUB_INIT_ASINC_WRT, SUB_INIT_ASINC_READ, SUB_INIT_SERIAL_INT, SUB_TRANSF, SUB_RECEIVE)
	
ORG 00H
/* P3.2 is the trigger
** P2.4 to P2.7 is the hex input of the keyboard matrix processing
** P0.0 is the order button
** P0.1 is the clear button
** 00H is the bit address for the first digit or second digit
** R5 delay register
** R1 data memory pointer register
** R3 is the number counter
*/
CURSOR_LEFT_COMMAND EQU 10H
CURSOR_RIGHT_COMMAND EQU 14H
		
FIRST_DIGIT_BIT EQU 00H
CURRENT_POS_BYTE EQU 40H
NUMBER_COUNT_BYTE EQU 41H
STARTING_POS_BYTE EQU 42H
DIGIT_SAVE_BYTE EQU 43H

SJMP MAIN

ORG 23H
SERIAL_INT: 
               MOV A, NUMBER_COUNT_BYTE
			   CJNE A, #0AH, PROCESS_DIGIT
               SJMP WAIT_UNPRESS ; There are ten numbers displayed, ignore any new digits received

PROCESS_DIGIT: LCALL SUB_RECEIVE ; Serial receive
			   ANL A, #00001111B
	           JNB FIRST_DIGIT_BIT, FIRST_DIGIT
			   ;SWAP A
			   MOV DIGIT_SAVE_BYTE, A
			   ACALL SUB_DISP_ONE_DIGIT_NUM
			   MOV A, DIGIT_SAVE_BYTE
			   MOV R1, CURRENT_POS_BYTE
			   
			   ADD A, @R1
			   MOV @R1, A
			   MOV A, #' '
			   ACALL SUB_DATAWRT
			   ACALL SUB_DELAY
			  
			   INC CURRENT_POS_BYTE ; Increment the number pointer
			   INC NUMBER_COUNT_BYTE ; Increment the number counter 
			   CPL FIRST_DIGIT_BIT
			   
			   ; Count the numbers displayed on one row
			   MOV A, NUMBER_COUNT_BYTE
			   CJNE A, #05H, WAIT_UNPRESS
			   ; Number of integers equal to 5, jump to second line
			   MOV A, #0C1H
			   ACALL SUB_COMMANDWRT
			   ACALL SUB_DELAY
			   SJMP WAIT_UNPRESS
			   			   
FIRST_DIGIT:   MOV R1, CURRENT_POS_BYTE
               SWAP A
               MOV @R1, A
			   SWAP A ; Unswap
               ;SWAP A ; Move the digit to the low nibble to display it on the LCD
			   ACALL SUB_DISP_ONE_DIGIT_NUM
               CPL FIRST_DIGIT_BIT
               
WAIT_UNPRESS:  JNB P3.2, WAIT_UNPRESS
               RETI
			   
; ------------------------- MAIN -------------------------------
MAIN: 
      ACALL SUB_INIT
	  CLR FIRST_DIGIT_BIT
	  MOV STARTING_POS_BYTE, #30H
	  MOV NUMBER_COUNT_BYTE, #00H
	  MOV CURRENT_POS_BYTE, STARTING_POS_BYTE
	  MOV P0, #00000011B ;Set P0.0 and P0.1 as inputs
	  MOV P2, #0F0H ; High nibble of P2 as inputs
      SETB P3.2 ; P3.2 as input
	  ACALL SUB_DELAY ; Delay to allow P3.2 to be grounded by external hardware
	  LCALL SUB_INIT_ASINC_READ
      LCALL SUB_INIT_SERIAL_INT
	  
HERE: JB P0.0, CLEAR_PRESSED
      JB P0.1, SORT_PRESSED
      SJMP HERE
      
CLEAR_PRESSED: CLR IE.0 ; Stop interrupts temporarily
               MOV CURRENT_POS_BYTE, STARTING_POS_BYTE
			   MOV NUMBER_COUNT_BYTE, #00H
			   ;ACALL SUB_INIT
			   ACALL SUB_CLR_SCREEN
			   SETB IE.0
CLEAR_STOP:	   JB P0.0, CLEAR_STOP
			   SJMP HERE

SORT_PRESSED:  MOV A, NUMBER_COUNT_BYTE
               CJNE A, #02H, CHECK_LT_2
CHECK_LT_2:    JC HERE
               CLR IE.0
               LCALL SUB_ORDER
			   LCALL SUB_DISPLAY_LIST
			   SETB IE.0
SORT_STOP:	   JB P0.1, SORT_STOP
			   SJMP HERE
			   
               

/*
** Subroutine that takes in a number in two-digit hexadecimal format at A and displays it on a LCD screen
*/
SUB_DISP_TWO_DIGIT_NUM: 
                 MOV B, #10H ; Set B to 16H
                 DIV AB ; Divide Acc by 16H, A will store the first digit and B the second digit of the Acc
				 ; 37H
				 
                 ACALL SUB_DISP_ONE_DIGIT_NUM
				 MOV A, B
				 ACALL SUB_DISP_ONE_DIGIT_NUM			 
				 
				 MOV A, #' '
				 ACALL SUB_DATAWRT
				 ACALL SUB_DELAY
				 RET
/*
** Subroutine that takes in a number in one-digit hexadecimal format at A (LSBs) and displays it on a LCD screen
*/				 
SUB_DISP_ONE_DIGIT_NUM: 
                 CJNE A, #0AH, CHECK_CHAR
CHECK_CHAR:      JC NUM_CHAR ;Check if the number in A is lesser than 10 or 0AH
LETTER_CHAR:     ADD A, #37H ; Add 37H to make the digit in A to the hex of its Ascii character as a letter
                 SJMP DISP_CHAR
NUM_CHAR:		 ADD A, #30H ; Add 30H to make the digit in A to the hex of its Ascii character as a number
DISP_CHAR:		 ACALL SUB_DATAWRT
				 ACALL SUB_DELAY
				 RET
/*
** Display on a LCD the numbers stored in D:30H through D:39H
*/
SUB_DISPLAY_LIST: 
                 MOV R3, #05H ; Max number of integers per line, if each one is two digits + ' '
                 MOV R2, NUMBER_COUNT_BYTE; Number of integers to be displayed
				 MOV R1, STARTING_POS_BYTE; Pointer to the first number of the number list
				 MOV A, #81H ;Move cursor to line 1, position 1
                 ACALL SUB_COMMANDWRT
				 ACALL SUB_DELAY
DISPLAY_NEXT:    MOV A, @R1
                 ACALL SUB_DISP_TWO_DIGIT_NUM
				 INC R1
				 DJNZ R3, NEXT_CHAR
NEXT_LINE:       MOV R3, #05H
                 MOV A, #0C1H
                 ACALL SUB_COMMANDWRT
				 ACALL SUB_DELAY
NEXT_CHAR:		 DJNZ R2, DISPLAY_NEXT
				 RET



			 
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
			   ;MOV A, #84H ; Move cursor to line 1, position 3
			   ;ACALL SUB_COMMANDWRT
			   ;ACALL SUB_DELAY
			   RET
/*
** Subroutine that clears the LCD screen
*/
SUB_CLR_SCREEN:
               MOV R0, #10H
			   MOV A, #81H
			   ACALL SUB_COMMANDWRT
			   ACALL SUB_DELAY
			   MOV A, #' '
CLR_CHAR_L1:   ACALL SUB_DATAWRT
               ACALL SUB_DELAY
			   DJNZ R0, CLR_CHAR_L1
			   
			   MOV R0, #10H
			   MOV A, #0C1H
			   ACALL SUB_COMMANDWRT
			   ACALL SUB_DELAY
			   MOV A, #' '
CLR_CHAR_L2:   ACALL SUB_DATAWRT
               ACALL SUB_DELAY
			   DJNZ R0, CLR_CHAR_L2
			   MOV A, #81H
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
           MOV R5, #02H
REPEAT:    MOV TH0, #3CH
           MOV TL0, #0B0H
           MOV TMOD, #01H
           SETB TR0
		   LOOP_WAIT: JNB TF0, LOOP_WAIT
		   CLR TR0
		   CLR TF0
		   DJNZ R5, REPEAT
		   RET

/*
** Subroutine that sorts x numbers in data mermory starting from the address held in STARTING_POS_BYTE
** where x is the number of numbers stored in NUMBER_COUNT_BYTE
*/
SUB_ORDER: 	
           ; First address of the array of numbers	
		   MOV R0, STARTING_POS_BYTE
		   MOV R1, STARTING_POS_BYTE
		   INC R1
	
	       ; Size of each loop
		   MOV B, NUMBER_COUNT_BYTE
		   DEC B
	       MOV R2, B
	       MOV R3, B
	
	       ; Bubble sort
	       CHECK: MOV A, @R0
	              SUBB A, @R1 
                  JNC XCHNG
		   
           ; Add by one the R0 and R1 pointers
           NEXT:  INC R0
	              INC R1
		          DJNZ R2, CHECK
		   
		   ; The inner loop finished: reload the inner loop and start again
		   MOV R2, B
		   MOV R0, STARTING_POS_BYTE
		   MOV R1, STARTING_POS_BYTE
		   INC R1
		   DJNZ R3, CHECK
           
		   RET

    XCHNG: CLR C
           MOV A, @R1
           XCH A, @R0
           XCH A, @R1
           SJMP NEXT


END
