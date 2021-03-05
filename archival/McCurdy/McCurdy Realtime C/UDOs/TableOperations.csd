TransformTableContents.csd
Written by Iain McCurdy 2010, updated 2011,2012.
adapted from ShuffleTableContents.csd

<CsoundSynthesizer>

<CsOptions>
-odevaudio -b400 -d -m0
</CsOptions>

<CsInstruments>
sr 	=	44100
ksmps 	=	10
nchnls 	=	1
0dbfs	=	1	;MAXIMUM AMPLITUDE

;FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLcolor	255, 255, 255, 0, 0, 0
;			LABEL           | WIDTH | HEIGHT | X | Y
	FLpanel	"Shuffle Table Contents",  500,    200,    0,  0

;SWITCHES                                		ON | OFF | TYPE | WIDTH | HEIGHT | X | Y | OPCODE | INS | STARTTIM | DUR
gk,ihPlay	FLbutton	"@DnArrow   Play",	1,    0,    21,    120,     30,    3,  5,     0,      3,      0,      0	;ZERO DURATION IS VALID WHEN THE TRIGGERED INSTRUMENT ONLY NEEDS TO PERFORM I-TIME OPERATIONS
gk,ih		FLbutton	"Shuffle",		1,    0,    21,    120,     30,  128,  5,     0,      1,      0,      0
gk,ih		FLbutton	"Retrograde",		1,    0,    21,    120,     30,  253,  5,     0,      5,      0,      0
gk,ih		FLbutton	"Reset",		1,    0,    21,    120,     30,  378,  5,     0,      6,      0,      0
gk,ih		FLbutton	"Add",	 		1,    0,    21,     70,     20,   90, 70,     0,      7,      0,      0
gk,ih		FLbutton	"Multiply",	 	1,    0,    21,     70,     20,  170, 70,     0,      8,      0,      0
gk,ih		FLbutton	"Add Rand.",	 	1,    0,    21,     90,     20,  250, 70,     0,      9,      0,      0
gk,ih		FLbutton	"Mult. Rand.",	 	1,    0,    21,     90,     20,  350, 70,     0,     10,      0,      0
gk,ih		FLbutton	"Min",	 		1,    0,    21,     45,     20,  450, 70,     0,     15,      0,      0
gk,ih		FLbutton	"Ascending",	 	1,    0,    21,     90,     20,   90,110,     0,     11,      0,      0
gk,ih		FLbutton	"Descending",	 	1,    0,    21,     90,     20,  190,110,     0,     12,      0,      0
gk,ih		FLbutton	"Integer",	 	1,    0,    21,     70,     20,  290,110,     0,     13,      0,      0
gk,ih		FLbutton	"Round",	 	1,    0,    21,     70,     20,  370,110,     0,     14,      0,      0
gk,ih		FLbutton	"Max",	 		1,    0,    21,     45,     20,  450,110,     0,     16,      0,      0
FLsetColor	0,255,0,ihPlay

;SLIDERS						MIN  | MAX | EXP | TYPE |   DISP    | WIDTH | HEIGHT | X | Y
gkgain, ihgain		FLslider 	"Level",	0,       1,   0,    3,      -1,      120,     15,    3,  35
FLsetVal_i	0.2,ihgain

;VALUE INPUT BOXES					MIN | MAX | STEP | TYPE | WIDTH | HEIGHT | X  | Y
gkval, ihval		FLtext		"Value",	-100, 100,  0.01,   1,     70,     20,     10, 70
gkval2, ihval2		FLtext		"(Value 2)",	-100, 100,  0.01,   1,     70,     20,     10, 110

;TEXT BOXES			MIN | MAX | STEP | TYPE | WIDTH | HEIGHT | X  | Y
gk1,  gih1	FLtext	"1", 	8,     9,    0,     1,      35,     20,   50,  150
gk2,  gih2	FLtext	"2", 	8,     9,    0,     1,      35,     20,   85,  150
gk3,  gih3	FLtext	"3", 	8,     9,    0,     1,      35,     20,  120,  150
gk4,  gih4	FLtext	"4", 	8,     9,    0,     1,      35,     20,  155,  150
gk5,  gih5	FLtext	"5", 	8,     9,    0,     1,      35,     20,  190,  150
gk6,  gih6	FLtext	"6", 	8,     9,    0,     1,      35,     20,  225,  150                       
gk7,  gih7	FLtext	"7", 	8,     9,    0,     1,      35,     20,  260,  150
gk8,  gih8	FLtext	"8", 	8,     9,    0,     1,      35,     20,  295,  150
gk9,  gih9	FLtext	"9", 	8,     9,    0,     1,      35,     20,  330,  150
gk10, gih10	FLtext	"10", 	8,     9,    0,     1,      35,     20,  365,  150
gk11, gih11	FLtext	"11", 	8,     9,    0,     1,      35,     20,  400,  150
gk12, gih12	FLtext	"12", 	8,     9,    0,     1,      35,     20,  435,  150

;TEXT BOXES					TYPE | FONT | SIZE | WIDTH | HEIGHT | X |  Y
ih		 	FLbox  	"Items", 	1,       5,    14,     50,     20,    0,  150

FLpanel_end

;INSTRUCTIONS AND INFO PANEL
				FLpanel	" ", 512, 560, 510, 0
				FLscroll     512, 560, 0,  0
;TEXT BOXES												TYPE | FONT | SIZE | WIDTH | HEIGHT | X | Y
ih		 	FLbox  	"                Transform Table Contents                     ", 	1,      5,     14,    490,    20,     5,   0
ih		 	FLbox  	"-------------------------------------------------------------", 	1,      5,     14,    490,    20,     5,  20
ih		 	FLbox  	"This example transforms the contents of a function table in a", 	1,      5,     14,    490,    20,     5,  40
ih		 	FLbox  	"variety of ways. Although a function table created using any ", 	1,      5,     14,    490,    20,     5,  60
ih		 	FLbox  	"GEN routine could be used it is probably most useful with a  ", 	1,      5,     14,    490,    20,     5,  80 
ih		 	FLbox  	"GEN 2 created list of numbers.                               ", 	1,      5,     14,    490,    20,     5, 100 
ih		 	FLbox  	"The table's contents in this example are the notes of a      ", 	1,      5,     14,    490,    20,     5, 120
ih		 	FLbox  	"chromatic scale in MIDI note number format from middle C to  ", 	1,      5,     14,    490,    20,     5, 140
ih		 	FLbox  	"the B above.                                                 ", 	1,      5,     14,    490,    20,     5, 160
ih		 	FLbox  	"'Shuffle' shuffles the contents of a function table in a     ", 	1,      5,     14,    490,    20,     5, 180
ih		 	FLbox  	"fashion similar to shuffling a deck of cards. Each time the  ", 	1,      5,     14,    490,    20,     5, 200
ih		 	FLbox  	"'Shuffle' button is clicked the order of these twelve items  ", 	1,      5,     14,    490,    20,     5, 220
ih		 	FLbox  	"is changed. The new table is printed to the terminal and to  ", 	1,      5,     14,    490,    20,     5, 240
ih		 	FLbox  	"the FL boxes and the table contents can be played in sequence", 	1,      5,     14,    490,    20,     5, 260
ih		 	FLbox  	"as a note row by clicking 'Play'.                            ", 	1,      5,     14,    490,    20,     5, 280
ih		 	FLbox  	"Table shuffling is achieved by sequencially swapping each    ", 	1,      5,     14,    490,    20,     5, 300
ih		 	FLbox  	"table item with another randomly chosen item.                ", 	1,      5,     14,    490,    20,     5, 320
ih		 	FLbox  	"'Retrograde' reverses the order of the table's contents.     ", 	1,      5,     14,    490,    20,     5, 340
ih		 	FLbox  	"Clicking on 'Reset' will reset the table to the original     ", 	1,      5,     14,    490,    20,     5, 360
ih		 	FLbox  	"ascending chromatic scale condition.                         ", 	1,      5,     14,    490,    20,     5, 380
ih		 	FLbox  	"Add will add 'Value' to each table item and 'Multiply' will  ", 	1,      5,     14,    490,    20,     5, 400
ih		 	FLbox  	"multiply 'Value' to each table item.                         ", 	1,      5,     14,    490,    20,     5, 420
ih		 	FLbox  	"'Add Rand.' will add a random value within the range 'Value' ", 	1,      5,     14,    490,    20,     5, 440
ih		 	FLbox  	"to 'Value 2' to each item in the table. A new random number  ", 	1,      5,     14,    490,    20,     5, 460
ih		 	FLbox  	"is generated for each addition. 'Mult. Rand.' multiplies each", 	1,      5,     14,    490,    20,     5, 480
ih		 	FLbox  	"value by a random number from 'Value' to 'Value 2'. A new    ", 	1,      5,     14,    490,    20,     5, 500
ih		 	FLbox  	"random value is generated for each multiplication.           ", 	1,      5,     14,    490,    20,     5, 520
ih		 	FLbox  	"Clicking on 'Integer' will remove the fractional part of all ", 	1,      5,     14,    490,    20,     5, 540
ih		 	FLbox  	"values. Clicking on 'Round' will round all values to the     ", 	1,      5,     14,    490,    20,     5, 560
ih		 	FLbox  	"nearest integer.                                             ", 	1,      5,     14,    490,    20,     5, 580
ih		 	FLbox  	"'Ascending' sorts values into ascending order, 'Descending'  ", 	1,      5,     14,    490,    20,     5, 600
ih		 	FLbox  	"into descending order.                                       ", 	1,      5,     14,    490,    20,     5, 620
ih		 	FLbox  	"'Min' finds and prints the smallest table value and its index", 	1,      5,     14,    490,    20,     5, 640
ih		 	FLbox  	"to the terminal and 'Max' does the same for the largest      ", 	1,      5,     14,    490,    20,     5, 660
ih		 	FLbox  	"value.                                                       ", 	1,      5,     14,    490,    20,     5, 680
ih		 	FLbox  	"Each of these procedures is created as a UDO for easy        ", 	1,      5,     14,    490,    20,     5, 700
ih		 	FLbox  	"transplantation into other projects.                         ", 	1,      5,     14,    490,    20,     5, 720
FLscroll_end
FLpanel_end                                                                                       

FLrun	;RUN THE FLTK WIDGET THREAD
;END OF FLTK INTERFACE CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

giTable		ftgen	0,0,-12,-2, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71	;CHROMATIC SCALE - 12 ITEMS - NEGATIVE TABLE SIZE PERMITS THE USE OF NON-ZERO TABLE SIZE

gisine		ftgen	0, 0, 4096, 10, 1						;A SINE WAVE
		seed	0								;SEED RANDOM NUMBER GENERATORS FROM THE SYSTEM CLOCK

opcode	tab_shuffle,0,i
	ifn		xin
	iNumItems	=	ftlen(ifn)			;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	icount 		= 	0				;INITIALISE COUNTER
	loop:							;LABEL
	ival1	table	icount, ifn				;READ A VALUE FROM SEQUENCIAL COUNTER TABLE LOCATION
	irndndx	random	0,iNumItems-0.001			;RANDOM TABLE INDEX USED TO CHOOSE SECOND ITEM
	ival2	table	irndndx, giTable				;READ SECOND VALUE FROM TABLE LOCATION
		tableiw	ival2, icount, ifn			;ITEM 2 WRITTEN TO ITEM 1'S LOCATION
		tableiw	ival1, irndndx, ifn			;ITEM 1 WRITTEN TO ITEM 2'S LOCATION
	;	OPCODE  COUNTER | INCREMENT | LIMIT | LABEL
		loop_lt	icount,       1,    iNumItems,loop	;LOOPING CONSTRUCTION
endop


opcode	tab_retrograde,0,i
	ifn		xin
	iNumItems	=		ftlen(ifn)			;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	iTableBuffer	ftgentmp	0,0,-iNumItems,-2, 0		;TEMPORARY BUFFER TABLE INITIALLY CONSISTING OF ZEROES
	icount		=		0				;INITIALISE COUNTER
	loop:								;LABEL - LOOPING LOOPS BACK TO HERE
	ival		table		iNumItems-icount-1, ifn		;READ VALUE FROM TABLE
			tableiw		ival, icount, iTableBuffer	;READ VALUE FROM MIRROR OPPOSITE POSITION IN TABLE
		loop_lt	icount,1,iNumItems,loop				;LOOPING CONSTRUCTION
	;COPY BUFFER TABLE BACK INTO ORIGINAL TABLE
	icount		=		0
	loop2:
	ival		table		icount,iTableBuffer
			tableiw		ival,icount,ifn
			loop_lt		icount,1,iNumItems,loop2
endop

opcode	tab_add_value,0,ii
	iaddval,ifn	xin
	iNumItems	=	ftlen(ifn)		;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	icount		=	0			;INITIALISE LOOP COUNTER
	loop:						;LABEL - LOOPING LOOPS BACK TO HERE
	ival		table	icount,ifn		;READ VALUE FROM TABLE
	ival		=	ival+iaddval            ;ADD VALUE
			tableiw	ival,icount,ifn		;WRITE NEW VALUE INTO LOCATION OF ORIGINAL VALUE
			loop_lt	icount,1,iNumItems,loop	;LOOPING CONSTRUCTION
endop

opcode	tab_mult_value,0,ii
	imultval,ifn	xin
	iNumItems	=	ftlen(ifn)		;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	icount		=	0			;INITIALISE LOOP COUNTER
	loop:						;LABEL - LOOPING LOOPS BACK TO HERE
	ival		table	icount,ifn		;READ VALUE FROM TABLE
	ival		=	ival*imultval		;MULTIPLY BY VALUE
			tableiw	ival,icount,ifn		;WRITE NEW VALUE INTO LOCATION OF ORIGINAL VALUE
			loop_lt	icount,1,iNumItems,loop	;LOOPING CONSTRUCTION
endop

opcode	tab_add_random,0,iii
	imin,imax,ifn	xin
	iNumItems	=	ftlen(ifn)		;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	icount		=	0                               ;INITIALISE LOOP COUNTER
	loop:                                      	;LABEL - LOOPING LOOPS BACK TO HERE
	ival		table	icount,ifn		;READ VALUE FROM TABLE
	iRAdd		random	imin,imax		;CREATE A RANDOM VALUE
	ival		=	ival+iRAdd		;ADD RANDOM VALUE
			tableiw	ival,icount,ifn		;WRITE NEW VALUE INTO LOCATION OF ORIGINAL VALUE
			loop_lt	icount,1,iNumItems,loop	;LOOPING CONSTRUCTION
endop

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

opcode	tabsort_ascnd,0,i
	ifn		xin
	;---DERIVE MAXIMUM VALUE---
	iNumItems	=	ftlen(ifn)			;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	imax	table	0,ifn					;STARTING VALUE IN THE SEARCH FOR  FOR THE MAXIMUM
	icount	=	1					;COUNTER STARTS AT ONE (WE'VE ALREADY READ VALUE ZERO)
	loop1:							;LABEL - BEGINING OF SUMMING LOOP
	  ival	table	icount,ifn				;READ VALUE FROM TABLE
	  imax = (ival>=imax?ival:imax)				;IF VAL IS BIGGER THAN CURRENT MAXIMUM THEN MAKE IT THE NEW MAXIMUM
	loop_lt	icount,1,iNumItems,loop1			;LOOP BACK TO 'loop1' UNTIL LOOPING COMPLETE
		
	;---SORT INTO ASCENDING ORDER---
	;THIS CONSISTS OF TWO LOOPS: THE MAIN LOOP WILL BE EXECUTED iNumItems TIMES
	;                            THE SUB LOOP WILL BE EXECUTED iNumItems x iNumItems TIMES
	iTableBuffer	ftgentmp	0,0,-iNumItems,-2, 0	;TEMPORARY BUFFER TABLE INITIALLY CONSISTING OF ZEROES - WILL BE USED TO STORE
	icount1		=	0				;INITIALISE MAIN LOOP COUNTER
	loop2:							;LABEL - MAIN LOOPING LOOPS BACK TO HERE
	  icount2	=	0				;RE-INITIALISE SUB-LOOP COUNTER AT THE BEGINNING OF EACH PRIMARY LOOP
	  imin		=	imax				;INITIALISE 'MINIMUM' TO THE MAXIMUM VALUE - RESET AT THE BEGINNING OF EACH PRIMARY LOOP
	  loop3:						;LABEL - SUB-LOOP LOOPS BACK TO HERE
	    ival	table	icount2,ifn			;READ VALUE FROM TABLE...
	    if ival<=imin then					;...IF IT IS SMALLER THAN OR EQUAL TO THE CURRENT MINIMUM VALUE... ('EQUAL TO' IS REQUIRED IN THE EVENTUALITY THAT TWO TABLE ITEMS ARE THE SAME)			
	      imin = ival					;...MAKE IT THE NEW MINIMUM
	      iloc = icount2					;REMEMBER ITS LOCATION - IF IT IS THE FINAL MINIMUM IN THIS SEARCH IT WILL HAVE TO BE SET TO A VERY HIGH VALUE SO WE DON'T FIND IT IN SUBSEQUENT SEARCHES 
	    endif
	    loop_lt	icount2,1,iNumItems,loop3		;SUB-LOOP LOOPS BACK TO 'LOOP2BEGIN' UNTIL COUNTER REACH THE END OF THE TABLE
	  tableiw	imin,icount1,iTableBuffer		;WRITE THE MINIMUM VALUE FOUND INTO THE BUFFER TABLE
	  tableiw	imax,iloc,ifn				;SET THE MINIMUM VALUE IN THE ORIGINAL TABLE TO THE MAXIMUM VALUE SO THAT WE DON'T FIND IT AGAIN
	  loop_lt	icount1,1,iNumItems,loop2		;LOOPING CONSTRUCTION
	;COPY BUFFER TABLE BACK INTO ORIGINAL TABLE
	icount		=		0
	loop4:
	ival		table		icount,iTableBuffer
			tableiw		ival,icount,ifn
			loop_lt		icount,1,iNumItems,loop4
endop

opcode	tabsort_dscnd,0,i
	ifn		xin
	;---DERIVE MAXIMUM VALUE---
	iNumItems	=	ftlen(ifn)			;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	imax	table	0,ifn					;STARTING VALUE IN THE SEARCH FOR  FOR THE MAXIMUM
	icount	init	1					;COUNTER STARTS AT ONE (WE'VE ALREADY READ VALUE ZERO)
	loop1:							;LABEL - BEGINING OF SUMMING LOOP
	  ival	table	icount,ifn				;READ VALUE FROM TABLE
	  imax = (ival>=imax?ival:imax)				;IF VAL IS BIGGER THAN CURRENT MAXIMUM THEN MAKE IT THE NEW MAXIMUM
	  		loop_lt	icount,1,iNumItems,loop1	;LOOP BACK TO 'LOOP0BEGIN' UNTIL LOOPING COMPLETE
		
	;---SORT INTO DESCENDING ORDER---
	;THIS CONSISTS OF TWO LOOPS: THE MAIN LOOP WILL BE EXECUTED 11 TIMES
	;                            THE SUB LOOP WILL BE EXECUTED 11x11 (121) TIMES
	iTableBuffer	ftgentmp	0,0,-iNumItems,-2, 0	;TEMPORARY BUFFER TABLE INITIALLY CONSISTING OF ZEROES - WILL BE USED TO STORE
	icount1		=	0				;INITIALISE MAIN LOOP COUNTER
	loop2:							;LABEL - MAIN LOOPING LOOPS BACK TO HERE
	  icount2	=	0				;RE-INITIALISE SUB-LOOP COUNTER AT THE BEGINNING OF EACH PRIMARY LOOP
	  imin		=	imax				;INITIALISE 'MINIMUM' TO MAXIMUM - RESET AT THE BEGINNING OF EACH PRIMARY LOOP
	  loop3:						;LABEL - SUB-LOOP LOOPS BACK TO HERE
	    ival	table	icount2,ifn			;READ VALUE FROM TABLE...
	    if ival<=imin then					;...IF IT IS SMALLER THAN OR EQUAL TO THE CURRENT MINIMUM VALUE... ('EQUAL TO' IS REQUIRED IN THE EVENTUALITY THAT TWO TABLE ITEMS ARE THE SAME)			
	      imin 	= 	ival				;...MAKE IT THE NEW MINIMUM
	      iloc 	= 	icount2				;REMEMBER ITS LOCATION - IF IT IS THE FINAL MINIMUM IN THIS SEARCH IT WILL HAVE TO BE SET TO A VERY HIGH VALUE SO WE DON'T FIND IT IN SUBSEQUENT SEARCHES 
	    endif
	    		loop_lt	icount2,1,iNumItems,loop3	;SUB-LOOP LOOPS BACK TO 'LOOP2BEGIN' UNTIL COUNTER REACH THE END OF THE TABLE
	  tableiw	imin,iNumItems-icount1-1,iTableBuffer	;WRITE THE MINIMUM VALUE FOUND INTO THE BUFFER TABLE
	  tableiw	imax,iloc,ifn				;SET THE MINIMUM VALUE IN THE ORIGINAL TABLE TO THE MAXIMUM VALUE SO THAT WE DON'T FIND IT AGAIN
	  		loop_lt	icount1,1,iNumItems,loop2	;LOOPING CONSTRUCTION
	;COPY BUFFER TABLE BACK INTO ORIGINAL TABLE
	icount		=		0
	loop4:
	ival		table		icount,iTableBuffer
			tableiw		ival,icount,ifn
			loop_lt		icount,1,iNumItems,loop4
endop

opcode	tab_integerise,0,i
	ifn		xin
	iNumItems	=	ftlen(ifn)			;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	icount		=	0				;INITIALISE LOOP COUNTER
	loop:							;LABEL - LOOPING LOOPS BACK TO HERE
	ival		table	icount,ifn			;READ VALUE FROM TABLE
	ival		=	int(ival)			;INTEGERISE VALUE
			tableiw	ival,icount,ifn			;WRITE NEW VALUE INTO LOCATION OF ORIGINAL VALUE
			loop_lt	icount,1,iNumItems,loop		;LOOPING CONSTRUCTION
endop


opcode	tab_round,0,i
	ifn		xin
	iNumItems	=	ftlen(ifn)		;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	icount		=	0			;INITIALISE LOOP COUNTER
	loop:						;LABEL - LOOPING LOOPS BACK TO HERE
	ival		table	icount,ifn		;READ VALUE FROM TABLE
	ival		=	round(ival)		;ROUND VALUES TO THE NEAREST INTEGER
			tableiw	ival,icount,ifn		;WRITE NEW VALUE INTO LOCATION OF ORIGINAL VALUE
			loop_lt	icount,1,iNumItems,loop	;LOOPING CONSTRUCTION
endop

              opcode         tabmin,ii,i	        ; UDO for deriving minimum value and its index from a table
itabnum       xin     
inumitems     =              ftlen(itabnum)             ; derive number of items in table
imin          table          0,itabnum                  ; minimum value starts as first table item
icount        init           1                          ; counter starts at 1 (we've already read item 0)
loop:                                                   ; loop 1 beginning
ival          table          icount,itabnum             ; read value from table
if ival<=imin then					; if value read from table is lower than (or equal to) current minimum...
 imin	=	ival					; ...values becomes new minimum
 indx	=	icount					; index of minimum becomes the index of this value
endif							; end of conditional branch
              loop_lt        icount,1,inumitems,loop    ; conditionally loop back
	      xout           imin,indx			; return minimum value & its index to caller instrument
              endop

	      opcode         tabmax,ii,i		; UDO for deriving maximum value and its index from a table
itabnum       xin     
inumitems     =              ftlen(itabnum)             ; derive number of items in table
imax          table          0,itabnum                  ; maximum value starts as first table items
icount        init           1                          ; counter starts at 1 (we've already read item 0)
loop:                                                   ; loop 1 beginning
ival          table          icount,itabnum             ; read value from table
if ival>=imax then					; if value read from table is higher than (or equal to) current maximum...
 imax	=	ival					; ...values becomes new maximum
 indx	=	icount					; index of maximum becomes the index of this value
endif							; end of conditional branch
              loop_lt        icount,1,inumitems,loop    ; conditionally loop back
	      xout           imax,indx			; return maximium value to caller instrument
              endop   

	      
	      
instr	1	;SHUFFLE TABLE CONTENTS
	prints	"shuffle"
		tab_shuffle	giTable			;CALL UDO
	event_i	"i", 2, 0, 0.1				;PRINT TABLE VALUES
endin

instr	2	;PRINT TABLE VALUES TO COMMAND LINE AND FL BOXES
	iNumItems	=	ftlen(giTable)		;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	prints "\\n"					;NEWLINE
	icount	init	0				;INITIALISE COUNTER
	LOOPBEGIN:					;LABEL
		ival	table	icount, giTable		;READ VALUE FROM TABLE
		print	ival				;PRINT READ VALUE TO THE TERMINAL
		FLsetVal_i	ival,gih1+icount	;WRITE THE READ VALUE INTO THE FLVALUE WIDGET
		loop_lt	icount,1,iNumItems,LOOPBEGIN	;LOOPING CONSTRUCTION
endin

instr	3	;TRIGGER NOTES IN SOUND GENERATING INSTRUMENT
	iNumItems	=	ftlen(giTable)		;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	igap	init	0.2				;INITIAL GAP BETWEEN PLAYED NOTES 
	iwhen	init	0				;TIME TO PLAY INITIAL NOTE (I.E. IMMEDIATELY)
	icount	init	0				;COUNTER FOR THE LOOP
	LOOPBEGIN:					;A LABEL - LOOPING LOOPS BACK TO HERE
	  ipch	table	icount, giTable			;READ PITCH (pch FORMAT) FROM TABLE ACCORDING TO WHERE WE ARE IN THE SEQUENCE
	  event_i		"i",4, iwhen, 0.6, ipch	;CREATE A NOTE EVENT TO BE PLAYED BY INSTR 3
	  iwhen	=	iwhen + igap			;CREATE THE TIME THE NEXT NOTE WILL BE PLAYED
	  igap	=	igap * 1.05			;GAP BETWEEN NOTES INCREASES AS WE PROGRESS RESULT IN A RALLENTANDO (SLOWING DOWN) AS THE SEQUENCE IS PLAYED
	  	loop_lt	icount,1,iNumItems,LOOPBEGIN	;LOOPING CONSTRUCTION
endin

instr	4	;SOUND GENERATING INSTRUMENT
	aenv	linseg	0,0.001,i(gkgain),p3-0.001,0	;CREATE AN AMPLITUDE ENVELOPE
	a1	oscili	aenv, cpsmidinn(p4), gisine	;GENERATE AN AUDIO SIGNAL (PITCH RECEIVED FROM INSTR 2 VIA p4)
		out	a1				;SEND AUDIO TO OUTPUT
endin

instr	5	;PERFORM RETROGRADE
	prints	"retrograde"
			tab_retrograde	giTable		;CALL UDO
			event_i		"i", 2, 0.1, 0	;PRINT TABLE VALUES
endin

instr	6	;RE-WRITE TABLE IN THE ORIGINAL ORDER
	prints	"rewrite table to original setting"
	iNumItems	=	ftlen(giTable)		;DERIVE THE NUMBER OF ITEMS IN THE FUNCTION TABLE
	icount		init	0			;INITIALISE LOOP COUNTER
	LOOPBEGIN:					;LABEL - LOOPING LOOPS BACK TO HERE
		tableiw	60+icount,icount,giTable	;WRITE 60+COUNTER INTO LOCATION OF TABLE CORRESPONDING TO THE COUNTER VALUE
		loop_lt	icount,1,iNumItems,LOOPBEGIN	;LOOPING CONSTRUCTION
	event_i	"i", 2, 0, 0				;PRINT TABLE VALUES
endin

instr	7	;ADD VALUE
	prints	"add a user defined value to each table item"
		tab_add_value	i(gkval),giTable	;CALL UDO
	event_i	"i", 2, 0, 0				;CALL INSTRUMENT THAT PRINTS TABLE VALUES
endin

instr	8	;MULTIPLY VALUE
	prints	"multiply each table item by a user defined value"
		tab_mult_value	i(gkval),giTable	;CALL UDO
	event_i	"i", 2, 0, 0				;CALL INSTRUMENT THAT PRINTS TABLE VALUES
endin

instr	9	;ADD RANDOM VALUE
	prints	"add a user random value to each table item"
		tab_add_random	i(gkval),i(gkval2),giTable	;CALL UDO
	event_i	"i", 2, 0, 0					;CALL INSTRUMENT THAT PRINTS TABLE VALUES
endin

instr	10	;MULTIPLY BY RANDOM VALUE
	prints	"Multiply each table item by a random value:"
		tab_mult_random	i(gkval),i(gkval2),giTable	;CALL UDO
	event_i	"i", 2, 0, 0					;CALL INSTRUMENT THAT PRINTS TABLE VALUES
endin

instr	11	;SORT INTO ASCENDING ORDER
	prints	"Sort into ascending order:"
		tabsort_ascnd	giTable				;CALL UDO
	event_i	"i", 2, 0, 0					;CALL INSTRUMENT THAT PRINT TABLE VALUES TO THE TERMINAL AND TO THE FL BOXES
endin

instr	12	;SORT INTO DESCENDING ORDER
	;THE PROCEDURE FOR SORTING TABLE ITEMS INTO DESCENDING ORDER IS ALMOST THE SAME AS FOR SORTING INTO ASCENDING ORDER.
	;THE ONLY DIFFERENCE IS THAT SORTED ITEMS ARE WRITTEN INTO THE TABLE STARTING FROM THE END AND WORKING BACKWARDS.
	prints	"Sort into descending order:"
		tabsort_dscnd	giTable			;CALL UDO
	event_i	"i", 2, 0, 0				;CALL INSTRUMENT THAT PRINT TABLE VALUES TO THE TERMINAL AND TO THE FL BOXES
endin

instr	13	;INTEGERISE VALUES
	prints	"Round values down to the nearest integer:"
		tab_integerise	giTable			;CALL UDO
	event_i	"i", 2, 0, 0				;CALL INSTRUMENT THAT PRINTS TABLE VALUES
endin

instr	14	;ROUND VALUES TO THE NEAREST INTEGER
	prints	"Round values to the nearest integer:"
		tab_round	giTable			;CALL UDO
	event_i	"i", 2, 0, 0				;CALL INSTRUMENT THAT PRINTS TABLE VALUES
endin

instr	15
	imin,indx	tabmin	giTable						;CALL UDO
		prints	"Minimum Table Value: %3.3f%tIndex: %d%N",imin,indx	;PRINT MINIMUM VALUE AND ITS INDEX TO THE TERMINAL
endin

instr	16
	imax,indx	tabmax	giTable						;CALL UDO
		prints	"Maximum Table Value: %3.3f%tIndex: %d%N",imax,indx	;PRINT MAXIMUM VALUE & ITS INDEX TO THE TERMINAL
endin

</CsInstruments>

<CsScore>
i 2 0 0		;PRINT TABLE ITEMS TO CONSOLE AND FL BOXES AT THE BEGINNING OF PERFORMANCE
f 0 3600	;DUMMY SCORE EVENT KEEPS PERFORMANCE GOING
</CsScore>

</CsoundSynthesizer>
