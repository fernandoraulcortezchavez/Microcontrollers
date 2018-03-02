ORG 00H
	
    ; Output states kept in memory for later use	
	MOV 30H, #00010000b
	MOV 31H, #00110000b
	MOV 32H, #00100000b
	MOV 33H, #01100000b
	MOV 34h, #01000000b
	MOV 35H, #11000000b
	MOV 36H, #10000000b
	MOV 37H, #10010000b
	
	; Make Port 2 an output
	MOV P2, #00H
	
	; Make Port 1 an input
	MOV P1, #0FFH
	
    MAIN: MOV A, P1
	      ANL A, #00000011b
		  
		  CJNE A, #00H, NOT_FULL_FORWARD
		  ACALL SUB_FORWARD_FULL_STEP
		  SJMP MAIN
		  
		  NOT_FULL_FORWARD: CJNE A, #01H, NOT_HALF_FORWARD
		  ACALL SUB_FORWARD_HALF_STEP
		  SJMP MAIN
		  
		  NOT_HALF_FORWARD: CJNE A, #02h, NOT_FULL_BACKWARD
		  ACALL SUB_BACKWARD_FULL_STEP
		  SJMP MAIN
		  
		  NOT_FULL_BACKWARD: 
		  ACALL SUB_BACKWARD_HALF_STEP
		  SJMP MAIN
		  	
	SUB_FORWARD_FULL_STEP: MOV R0, #4H
	                       MOV R1, #30H
	   LOOP_FWD_FULL_STEP: MOV A, @R1
						   MOV P2, A
						   INC R1
						   INC R1
						   ACALL SUB_DELAY
						   DJNZ R0, LOOP_FWD_FULL_STEP
						   RET
	
	SUB_FORWARD_HALF_STEP: MOV R0, #8H
	                       MOV R1, #30H
	   LOOP_FWD_HALF_STEP: MOV A, @R1
						   MOV P2, A
						   INC R1
						   ACALL SUB_DELAY
						   DJNZ R0, LOOP_FWD_HALF_STEP
						   RET
	
	SUB_BACKWARD_FULL_STEP:  MOV R0, #4H
	                         MOV R1, #36H
	LOOP_BACKWARD_FULL_STEP: MOV A, @R1
						     MOV P2, A
						     DEC R1
						     DEC R1
						     ACALL SUB_DELAY
						     DJNZ R0, LOOP_BACKWARD_FULL_STEP
						     RET
	
	SUB_BACKWARD_HALF_STEP:  MOV R0, #8H
	                         MOV R1, #37H
	LOOP_BACKWARD_HALF_STEP: MOV A, @R1
						     MOV P2, A
						     DEC R1
						     ACALL SUB_DELAY
						     DJNZ R0, LOOP_BACKWARD_HALF_STEP
						     RET
						   
						   
	SUB_DELAY:  MOV R2, #0FFH
	            MOV R3, #01AH
	LOOP_DELAY: DJNZ R2, LOOP_DELAY
	            MOV R2, #0FFH
				DJNZ R3, LOOP_DELAY
				RET
			
END 
