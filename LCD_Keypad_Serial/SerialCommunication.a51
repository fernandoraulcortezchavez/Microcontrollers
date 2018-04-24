NAME 	SERIAL_COMM
;
PUBLIC	SUB_INIT_ASINC_WRT, SUB_INIT_ASINC_READ, SUB_INIT_SERIAL_INT, SUB_TRANSF, SUB_RECEIVE

SERIAL_ROUTINES  SEGMENT  CODE


	RSEG  SERIAL_ROUTINES
;-------------Serial Communication Initialization ---------------
SUB_INIT_ASINC_WRT:  MOV TMOD, #20H
				     MOV TH1, #-3
				     MOV SCON, #50H
				     SETB TR1
				     CLR TI
				     RET

SUB_INIT_ASINC_READ: MOV TMOD, #20H
				     MOV TH1, #-3
				     MOV SCON, #50H
				     SETB TR1
				     CLR RI
				     RET
				 
;-------------Serial Communication Interrupt Configuration ------
SUB_INIT_SERIAL_INT: SETB IE.7
                     SETB IE.4
					 RET
					 
;-------------Serial Data Transfer, Byte in A -------------
SUB_TRANSF: 
				 MOV SBUF, A
WAIT_T:  		 JNB TI, WAIT_T
				 CLR TI
				 RET
		
;-------------Serial Data Receive, Byte to A -------------		
SUB_RECEIVE:
WAIT_R:  		 JNB RI, WAIT_R
				 MOV A, SBUF
				 CLR RI
				 RET
		 
END
	
