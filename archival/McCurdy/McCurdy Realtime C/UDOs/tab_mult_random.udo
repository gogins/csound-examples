; MULTIPLY EACH MEMBER OF A FUNCTION TABLE BY A DIFFERENT RANDOM NUMBER
; imin  --  minimum value of random range from which a random number shall be chosen 
; imax  --  maximum value of random range from which a random number shall be chosen 
; ifn   --  number of table which will be modified 

opcode	tab_mult_random,0,iii
	imin,imax,ifn	xin
	iNumItems	=	ftlen(ifn)		;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	icount		=	0			;INITIALISE LOOP COUNTER
	loop:						;LABEL - LOOPING LOOPS BACK TO HERE
	ival	table	icount,ifn			;READ VALUE FROM TABLE
	iRMult	random	imin,imax			;CREATE A RANDOM VALUE
	ival	=	ival*iRMult			;MULTIPLY BY RANDOM VALUE
		tableiw	ival,icount,ifn			;WRITE NEW VALUE INTO LOCATION OF ORIGINAL VALUE
		loop_lt	icount,1,iNumItems,loop		;LOOPING CONSTRUCTION
endop

