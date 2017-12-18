 TITLE     MOV IT(EXE)
          .MODEL SMALL
          .STACK 200H
.DATA
;---------------------------------- VARIABLES ----------------------------------
 ROW           DB   0                                           ;variable for row
 COL           DB   0                                           ;variable for col

 FLAG          DB   0                                           ;flags
 TIME_FLAG	   DB   0                                           ;flags the current time
 TIME_DONE		 DB   0                                           ;flags the time completed

 SCORE				 DB   0                                           ;stores the score of the current player
 SCORE_MSG     DB   'SCORE: $'                                  ;score label
 BUF 	  			 DB   6 DUP ('$')                                 ;actual score

 CHECKER       DB   0                                           ;stores the current color display value
 TEMP          DB   ?                                           ;stores temporary values
 TIME 				 DB   ?                                           ;stores the current time


 HOME	         DB	   'screen.txt' , 0                           ;home screen file
 GAMEbg        DB    'bg.txt'     , 0                           ;background screen file
 LOADFile 	   DB 	 'load.txt'   , 0                           ;loading screen file
 HowToPlay     DB 	 'htp.txt'    , 0                           ;HTP screen file (htp means How to play)
 GAMEOVER	     DB 	 'ggo.txt'    , 0                           ;gameover screen file

 FILE_HANDLE	 DW	 ?                                            ;variable for file handling
 FILE_BUFFER	 DB 	  1896 DUP('$')                             ;file buffer
 LOAD	         DB	 'Moving...$'                                 ;Moving string label
 ERROR_STR	   DB	 'Error READING!!$'                           ;error string label
 COMPLETE	     DB	 'START!....$'                                ;start string label
 INIT	         DB	  0ah, 0dh, 20 DUP(219), '$'                  ;initial bar
 BAR		       DB	  219, '$'                                    ;variable of the extended ascii bar
 ARROW	       DB	  175, '$'                                    ;variable of the extended ascii arrow
 SPACE   		   DB   ' ', '$'                                    ;character used for clearing

 BEEPCX        DW   ?                                           ;beep/sound ctr
 BEEPBX        DB   ?                                           ;beep/sound value from the memory

.CODE
;------------------------------ FUNCTIONS / PROCS  -----------------------------
MAIN        PROC

            MOV     AX, @DATA
            MOV     DS, AX

          	CALL    HIDE_CURSOR
     				CALL    LOADING
            CALL    CLS0
            CALL    SET_SCRN
  					CALL    DISP_HOME

            EXIT:
            MOV 		AX, 4C00H
            INT 		21H
MAIN        ENDP
;-------------------- this function hides the blinking cursor  -----------------
HIDE_CURSOR PROC    NEAR
			      MOV     CX, 2000H
			      MOV     AH, 01H
			      INT     10H
			      RET
HIDE_CURSOR ENDP
;--------------------- cls used in displays screens ----------------------------
CLS0 					PROC		NEAR
							MOV			AX, 0600H
							MOV			BH, 0BH
							MOV			CX, 0000H
							MOV			DX, 184FH
							INT			10H
							RET
CLS0 					ENDP
;------------------------ loads the loading screen -----------------------------
LOADING 			PROC 		NEAR
							CALL 		CLS0
							LEA 		DX, LOADFile                             ;prints the loading file screen
							CALL 		FILE_READ

							MOV			ROW, 22
							MOV			COL, 23H

				SCRN:
				      CALL		SET_CURS
							CMP			FLAG, 0		                               ;checks flag if its done loading
							JE			START
							CMP			FLAG, 1
							JE			MENU

				START:
				      LEA			DX, LOAD	                               ;prints the string "Moving"
							JMP			SET

				SET:
				      CALL		SET_SCRN	                               ;loading bar
							CMP			FLAG, 1		                               ;exits after it has completed
							JE			BACK
							MOV			FLAG, 1		                               ;resets the screen after it has completed
							JMP			SCRN

				MENU:
				      CALL		SET_CURS	                               ;displays the menu screen after loading
							LEA			DX, COMPLETE
							CALL		PRINT

				BACK:
				      MOV			AH, 00H
							INT			16H
							RET
LOADING 	    ENDP
;-------- proc that compares if the input and displayed color matches-----------
COMPARE     PROC    NEAR

            CMP     TEMP, 4DH                                  ;if red
            JE      UP
            CMP     TEMP, 4BH                                  ;if cyan
            JE      DOWN
            CMP     TEMP, 48H                                  ;if blue
            JE      LEFT
            CMP     TEMP, 50H                                  ;if green
            JE      RIGHT
            CMP     TEMP, 01
            JE      QUIT

            UP:
              CALL    BEEP_up
              CMP     CHECKER, 4DH
              JE      LEAVE
              JMP     LEAVE_STILL

            DOWN:
              CALL    BEEP_down
              CMP     CHECKER, 4BH
              JE      LEAVE
              JMP     LEAVE_STILL

            LEFT:
              CALL    BEEP_left
              CMP     CHECKER, 48H
              JE      LEAVE
              JMP     LEAVE_STILL

            RIGHT:
              CALL    BEEP_right
              CMP     CHECKER, 50H
              JE      LEAVE
              JMP     LEAVE_STILL

            LEAVE_STILL:
              MOV     FLAG, 0
      			  CMP     SCORE, 0
      			  JE	    LEAVE3

      			  DEC 	  SCORE
              RET

            LEAVE:
			        INC 	  SCORE
              MOV     FLAG, 1
              RET

      			LEAVE3:
      				RET

            QUIT:
              CALL  EXIT
COMPARE     ENDP
;----------------------- displays the how to play screen -----------------------
DISP_HOWTO		PROC		NEAR
							MOV 		ROW, 0
							MOV 		COL, 0
							CALL 		SET_CURS
							CALL		CLS0
							LEA			DX, HOWTOPLAY
							CALL		FILE_READ
							MOV			AH, 00H
							INT			16H
              CALL    CLS0
							JMP    DISP_HOME
					    RET
DISP_HOWTO		ENDP
;-------------------------- displays the menu screen ---------------------------
DISP_HOME			PROC		NEAR	                           								
							MOV 		ROW, 0
							MOV 		COL, 0
							CALL 		SET_CURS
							CALL 		CLS0
							LEA 		DX, HOME
							CALL 		FILE_READ
							JMP 		MENU_CH
							RET
DISP_HOME			ENDP
;--------------------------- displays the menu screen --------------------------
DISP_BG			PROC		NEAR
							MOV 		ROW, 0
							MOV 		COL, 0
							CALL 		SET_CURS
							CALL 		CLS0
							LEA 		DX, GAMEbg
							CALL 		FILE_READ
							JMP 		MENU_CH
							RET
DISP_BG			ENDP
;------------------------ proc for the menu choices screen ---------------------
MENU_CH				PROC	 	NEAR

							MOV			ROW, 22
							MOV			COL, 15
							CALL		SET_CURS
							LEA			DX, ARROW
							CALL		PRINT

				CHOOSE:
				      MOV			AH, 00H		                            ;gets the user input
							INT			16H
							CMP 		AL, 0DH            	                  ;compares if the choice is enter
							JE			CHOICE
							CMP			AH, 4BH		                            ;compares if the input is the left key
							JE			LEFT1
							CMP			AH, 4DH		                            ;compares id the input is the right key
							JE			RIGHT1

							JMP			CHOOSE

				RIGHT1:                                             ;if right
				      CALL    BEEP_1
				      CMP			COL, 49
							JE			CHOOSE
							CALL		SET_CURS
							LEA			DX, SPACE
							CALL 		PRINT
							ADD			COL, 17
							CALL		DISP_ARR

				LEFT1:                                              ;if left
				      CALL    BEEP_1
				      CMP			COL, 15
							JE			CHOOSE
							CALL		SET_CURS
							LEA			DX, SPACE
							CALL 		PRINT
							SUB			COL, 17

				DISP_ARR:                                           ;displays the arrow
				      CALL		SET_CURS
							LEA			DX, ARROW
							CALL		PRINT

							JMP			CHOOSE

				CHOICE:                                            ;checks the choice of the user
				      CMP 		COL, 15
							JE			START_GAME
							CMP 		COL, 32
							JE			HOW_PG
							CMP 		COL, 49
							JE			FIN
							JMP 		CHOOSE

				HOW_PG:                                            ;option that calls the how to play screen
				      CALL    BEEP_2
              CALL    DISP_HOWTO
              RET

				FIN:                                               ;option that ends the game
				      CALL    BEEP_2
				      CALL		EXIT
				      RET

        START_GAME:                                        ;option that starts the game
              CALL    BEEP_2
              ;CALL    DISP_BG
              CALL    LOOP_GAME
              RET

MENU_CH				ENDP
;-------------------------- proc that loops the game ---------------------------
LOOP_GAME     PROC    NEAR


            ITERATE:

              MOV     BH, 0BH
              CALL    CLS
              CALL    PRINT_SCORE
      			  CALL 	  COMPARE_TIME
      			  CMP     TIME_DONE, 1
      			  JE 	    DISP_GAMEOVER
              CALL    RANDOMIZE
              CMP     DL, '1'
              JE      CHANGE1
              CMP     DL, '0'
              JE      CHANGE2
              CMP     DL, '2'
              JE      CHANGE3
              CMP     DL, '3'
              JE      CHANGE4
              JMP     ITERATE

            CHANGE1:
              MOV     CHECKER, 4BH
              MOV     BH, 10H
              JMP     LOOP_

            CHANGE2:
              MOV     CHECKER, 4DH
              MOV     BH, 20H
              JMP     LOOP_

            CHANGE3:
              MOV     CHECKER, 50H
              MOV     BH, 30H
              JMP     LOOP_

            CHANGE4:
              MOV     CHECKER, 48H
              MOV     BH, 40H
              JMP     LOOP_

            LOOP_:
              CALL    CLS2
              CALL    GET_KEY
              CALL    COMPARE
              CMP     FLAG, 1
              JE      ITERATE
              JMP     LOOP_
LOOP_GAME     ENDP
;------------------------ proc that prints the loading bar ---------------------
SET_SCRN			PROC		NEAR
							CALL		PRINT
              ;CALL    MUSIC

							LEA			DX, INIT                     	     ;prints the initial bar
							CALL 		PRINT
              MOV			CX, 60		                         ;set counter

				PROG:
				      CMP			FLAG, 1
							JE			SKIP		                           ;skip delay if complete
							CALL 		DELAY
				SKIP:
				      LEA			DX, BAR		                         ;prints the other bars
							CALL		PRINT
							LOOP		PROG

							RET
SET_SCRN			ENDP
;----------------------- proc that displays the gameover screen ----------------
DISP_GAMEOVER		PROC
      					MOV 		ROW, 00
      					MOV 		COL, 00
      					CALL 		SET_CURS
      					CALL 		CLS0
      					LEA 		DX, GAMEOVER
      					CALL 		FILE_READ
                CALL    MUSIC_GO

                MOV 		ROW, 01H
      					MOV 		COL, 1AH
                CALL		SET_CURS
                LEA     DX, BUF
                CALL    PRINT
                JMP     LAST

                LAST:
                    CALL 		GET_KEY
                    JMP      EXIT
      					RET
DISP_GAMEOVER		ENDP
;-------------------------- delays the a certain proc --------------------------
DELAY 				PROC 		NEAR
							MOV     BX, 003H

				MAINLP:
				      PUSH    BX
            	MOV     BX, 0D090H

				SUBLP:
				     DEC     BX
             JNZ     SUBLP
             POP     BX
             DEC     BX
             JNZ     MAINLP

			       RET
DELAY 			 ENDP
;----------------------------- sets the initial cursor -------------------------
SET_CURS 			PROC		NEAR
							MOV			AH, 02H
							MOV			BH, 00
							MOV			DH, ROW
							MOV			DL, COL
							INT			10H
							RET
SET_CURS 			ENDP
;--------------- randomly chooses one color from the 4 given colors ------------
RANDOMIZE   PROC
            MOV     AH, 00h
            INT     1AH

            MOV     AX, DX
            XOR     DX, DX
            MOV     CX, 4
            DIV     CX

            ADD     DL, '0'
            RET
RANDOMIZE   ENDP
;--------------------------------- clears screen -------------------------------
CLS         PROC
            MOV     AX, 0600H
            MOV     CX, 0000H
            MOV     DX, 184FH
            INT     10H
            RET
CLS         ENDP
;--------------------------- clears the smaller screen -------------------------
CLS2         PROC
            MOV     AX, 0600H
            MOV     CX, 0614H
            MOV     DX, 123CH
            INT     10H
            RET
CLS2         ENDP
;-------------------------------- file reads -----------------------------------
FILE_READ			PROC		NEAR
							MOV			AX, 3D02H											               ;opens the file
							INT			21H
							JC			_ERROR
							MOV			FILE_HANDLE, AX

							MOV			AH, 3FH												               ;reads the file
							MOV			BX, FILE_HANDLE
							MOV			CX, 1896
							LEA			DX, FILE_BUFFER
							INT			21H
							JC			_ERROR

							MOV			DX, 0500H										                ;displays the file
							CALL 		SET_CURS
							LEA			DX, FILE_BUFFER
							CALL 		PRINT

							MOV 		AH, 3EH         							              ;closes the file
							MOV 		BX, FILE_HANDLE
							INT 		21H
							JC 			_ERROR

							RET

			 _ERROR:
			        LEA			DX, ERROR_STR									             ;prints the error message in file operation
							CALL 		PRINT
							RET
				BK:
				      RET
FILE_READ			ENDP
;--------------------------- proc that prints/display strings ------------------
PRINT       PROC
            MOV     AH, 09
            INT     21H
            RET
PRINT       ENDP
;--------------------------- proc that prints the score ------------------------
PRINT_SCORE		PROC
				MOV 	ROW, 00
				MOV 	COL, 00
				CALL 	SET_CURS

				LEA 	DX, SCORE_MSG
				CALL 	PRINT

				CALL 	NUM_TO_STRING

				LEA 	DX, BUF
				CALL 	PRINT
				RET
PRINT_SCORE		ENDP
;---------------------------- proc that converts int to string  ----------------
NUM_TO_STRING	PROC                                              ;this procedure converts an integer to string
				XOR		AX, AX
				MOV 	AL, SCORE
				LEA		SI, BUF                                           ;prints the actual score

				MOV 	BX, 10
				MOV 	CX, 0

				CYCLE1:
					MOV		DX, 0
					DIV 	BX
					PUSH 	DX
					INC 	CX
					CMP		AX, 0
					JNE		CYCLE1

				CYCLE2:
					POP 	DX
					ADD 	DL, 48
					MOV 	[SI], DL
					INC 	SI
					LOOP 	CYCLE2

				RET
NUM_TO_STRING	ENDP
;--------------------------- sound effect for menu screen ----------------------
BEEP_1       PROC    NEAR                                     ;high pitch beep sound for menu option

             MOV	AL, 182
						 OUT 43H, AL
             MOV AX, 1111

						 OUT	42H, AL
						 MOV AL, AH
						 OUT 42H, AL
						 IN AL, 61H

						 OR AL, 00000011B
						 OUT 61H, AL
						 MOV BEEPBX, 25

						.PAUSE1a:
						 MOV BEEPCX, 2900
						.PAUSE2a:
						 DEC BEEPCX
						 JNE .PAUSE2a
						 DEC BEEPBX
						 JNE .PAUSE1a
						 IN AL, 61H

						 AND AL, 11111100B
						 OUT 61H, AL
						 RET
BEEP_1       ENDP
;------------------- sound effect for enter in the menu screen -----------------
BEEP_2       PROC     NEAR
             MOV	AL, 182
						 OUT 43H, AL
						 MOV AX, 8880


						 OUT 42H,  AL
						 MOV AL,   AH
						 OUT 42H,  AL
						 IN  AL,   61H

						 OR AL, 00000011B
						 OUT 61H, AL
						 MOV BEEPBX, 25

						.PAUSE1b:
						 MOV BEEPCX, 2900
						.PAUSE2b:
						 DEC BEEPCX
						 JNE .PAUSE2b
						 DEC BEEPBX
						 JNE .PAUSE1b
						 IN AL, 61H

						 AND AL, 11111100B
						 OUT 61H, AL
						 RET
BEEP_2       ENDP
;--------------------------- beep for up arrow key -----------------------------
BEEP_up       PROC     NEAR
             MOV	AL, 182
						 OUT 43H, AL
						 MOV AX, 9203


						 OUT	42H, AL
						 MOV  AL, AH
						 OUT  42H, AL
						 IN   AL, 61H

						 OR   AL, 00000011B
						 OUT  61H, AL
						 MOV  BEEPBX, 25

						.PAUSE1u:
						 MOV BEEPCX, 2900
						.PAUSE2u:
						 DEC BEEPCX
						 JNE .PAUSE2u
						 DEC BEEPBX
						 JNE .PAUSE1u
						 IN AL, 61H

						 AND AL, 11111100B
						 OUT 61H, AL
						 RET
BEEP_up      ENDP
;----------------------------- beep for down key -------------------------------
BEEP_down    PROC     NEAR
             MOV	AL, 182
						 OUT 43H, AL
						 MOV AX, 9090


						 OUT	42H, AL
						 MOV AL, AH
						 OUT 42H, AL
						 IN AL, 61H

						 OR AL, 00000011B
						 OUT 61H, AL
						 MOV BEEPBX, 25

						.PAUSE1d:
						 MOV BEEPCX, 2900
						.PAUSE2d:
						 DEC BEEPCX
						 JNE .PAUSE2d
						 DEC BEEPBX
						 JNE .PAUSE1d
						 IN AL, 61H

						 AND AL, 11111100B
						 OUT 61H, AL
						 RET
BEEP_down    ENDP
;------------------------------ beep for left key ------------------------------
BEEP_left    PROC     NEAR

             MOV	AL, 182
						 OUT 43H, AL
						 MOV AX,  6818

						 OUT 42H, AL
						 MOV AL,  AH
						 OUT 42H, AL
						 IN AL,   61H

						 OR AL, 00000011B
						 OUT 61H, AL
						 MOV BEEPBX, 25

						.PAUSE1l:
						 MOV BEEPCX, 2900
						.PAUSE2l:
						 DEC BEEPCX
						 JNE .PAUSE2l
						 DEC BEEPBX
						 JNE .PAUSE1l
						 IN AL, 61H

						 AND AL, 11111100B
						 OUT 61H, AL
						 RET
BEEP_left    ENDP
;------------------------------ beep for right key ------------------------------
BEEP_right   PROC     NEAR
             MOV	AL, 182
						 OUT 43H, AL
						 MOV AX,  7462

						 OUT	42H, AL
						 MOV AL, AH
						 OUT 42H, AL
						 IN AL, 61H

						 OR AL, 00000011B
						 OUT 61H, AL
						 MOV BEEPBX, 25

						.PAUSE1r:
						 MOV BEEPCX, 2900
						.PAUSE2r:
						 DEC BEEPCX
						 JNE .PAUSE2r
						 DEC BEEPBX
						 JNE .PAUSE1r
						 IN AL, 61H

						 AND AL, 11111100B
						 OUT 61H, AL
						 RET
BEEP_right   ENDP
;------------------------ music background for loading screen ------------------
MUSIC       PROC   NEAR
						MOV   AL, 182
						OUT   44H, AL

						OUT	42H, AL
						MOV AL, AH
						OUT 42H, AL
						IN AL, 61H

						OR AL, 00000011B
						OUT 61H, AL
						MOV BEEPBX, 25

						;-DELAY TO MAKE THE BEEP LONGER
						.PAUSE1:
						.PAUSE2:
						DEC BEEPCX
						JNE .PAUSE2
						DEC BEEPBX
						JNE .PAUSE1
						IN AL, 61H

						AND AL, 11111100B
						OUT 61H, AL
						RET
MUSIC       ENDP
;---------------------- music backgroundfor gameover screen  -------------------
MUSIC_GO    PROC   NEAR
						MOV   AL, 182
						OUT 43H, AL

						OUT	42H, AL
						MOV AL, AH
						OUT 42H, AL
						IN AL, 61H

						OR AL, 00000011B
						OUT 61H, AL
						MOV BEEPBX, 25

						;-DELAY TO MAKE THE BEEP LONGER
						.PAUSE1gameover:
						.PAUSE2gameover:
						DEC BEEPCX
						JNE .PAUSE2gameover
						DEC BEEPBX
						JNE .PAUSE1gameover
						IN AL, 61H

						AND AL, 11111100B
						OUT 61H, AL
						RET
MUSIC_GO      ENDP
;----------------------------- gets any key input ------------------------------
GET_KEY	    PROC	NEAR

          	MOV		AH, 00H
          	INT		16H

          	MOV		TEMP, AH

          	RET
GET_KEY 	  ENDP
;------------------------------ get the current time ---------------------------
GET_TIME 		PROC
      			MOV		AH, 2CH
      			INT 	21H
      			MOV 	TIME, DH
      			RET
GET_TIME 		ENDP
;----------------------------- proc that compares the time ---------------------
COMPARE_TIME	PROC
      				MOV 	AH, 2CH
      				INT 	21H
      				MOV 	BH, TIME
      				CMP 	BH, DH
      				JE		CHECK1
      				JNE 	CHECK2

      				CHECK1:
      					CMP		TIME_FLAG, 1
      					JE		GORA
      					JMP 	DONE

      				CHECK2:
      					MOV 	TIME_FLAG, 1
      					JMP		DONE

      				GORA:
      					MOV 	TIME_DONE, 1
      					JMP		DONE

      				DONE:
      					RET
COMPARE_TIME	ENDP
;---------------------------------------------------------------------

END
