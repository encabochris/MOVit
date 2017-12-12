TITLE        MOV IT (EXE)
            .MODEL SMALL
            .STACK 200H
;----------------------------------------------
HOME	      DB	 'ps-se.txt', 0
GHOST 	    DB 	 'ghost.txt', 0
HOW 	      DB 	 'how.txt', 0
FILE_HANDLE	DW	 ?
ERROR_STR	  DB	 'Error!$'
ERROR_STR2  DB   'ERROR!$'
FILE_BUFFER	DB 	  1896 DUP('$')
LOAD	      DB	 'Loading...$'
COMP	      DB	 'START!    $'
INIT	      DB	  0ah, 0dh, 20 DUP(219), '$'
BAR		      DB	  219, '$'
FLAG	      DB	  0
ARROW	      DB	  175, '$'
EMPTY	      DB	  '$'
ROW		      DB		0
COL		      DB		0
ROWD	 	    DB		6H, '$'
COLD	    	DB		0
;--------------------------------------------
          .CODE
MAIN 		   PROC  FAR

				   MOV 	 AX, @DATA
			     MOV   DS, AX

        	 CALL  HIDE_CURSOR
   				 CALL  LOADING
					 CALL   GAME_LOOP
			EXIT:
			    MOV   AX, 4C00H
			    INT   21H
MAIN 			ENDP
;----------------------------------------
WINNER     PROC  NEAR
           CALL  BACKGROUND3
           CALL	 DISP_MENU
WINNER     ENDP
;----------------------------------------
GAME_LOOP  PROC  NEAR
			MAIN_GAME:
				 CALL  DISP_HOME

          RET

GAME_LOOP ENDP
;--------------------------------------------
GETKEY 			PROC 	NEAR                             ;GETS the input from either PLAYER 1 or 2
						MOV		AH, 01H
						INT		16H

						JZ  	LEAVE

						MOV		AH, 00H
						INT		16H
						MOV 	TEMP1, AL
						CMP 	AH, 48H                          ;UP Input for PLAYER 2
						JE 		PU2
						CMP 	AH, 50H                          ;DOWN input for PLAYER 2
						JE 		PU2
						CMP 	AL, '7'                          ;UP input for PLAYER 1
						JE 		PU3
						CMP 	AL, '1'                          ;DOWN input for PLAYER 1
						JE 		PU3
						JMP   LEAVE
				PU2:
						MOV 	INPUT2, AH
						JMP 	LEAVE
				PU3:
						MOV 	INPUT1, AL
				LEAVE:
					  SUB  AX, AX
						RET
GETKEY 			ENDP
;----------------------------------------------
MOVECURSOR 	PROC 		NEAR
						MOV 		AH, 02H
						MOV 		BH, 00
						INT 		10H
						RET
MOVECURSOR 	ENDP
;----------------------------------------------
BACKGROUND1 PROC 		NEAR
						MOV 		AX, 0600H
						MOV 		BH, 0CH
						MOV 		CX, 0027H
						MOV 		DX, 184FH
						INT 		10H
						RET
BACKGROUND1 ENDP
;----------------------------------------------
BACKGROUND2 PROC 		NEAR
						MOV 		AX, 0600H
						MOV 		BH, 09H
						MOV 		CX, 0000H
						MOV 		DX, 184FH
						INT 		10H
						RET
BACKGROUND2 ENDP
;----------------------------------------------
BACKGROUND3 PROC 		NEAR
						MOV 		AX, 0600H
						MOV 		BH, 0CH
						MOV 		CX, 0000H
						MOV 		DX, 184FH
						INT 		10H
						RET
BACKGROUND3 ENDP
;----------------------------------------------
BACKGROUND4 PROC 		NEAR
						MOV 		AX, 0600H
						MOV 		BH, 09H
						MOV 		CX, 0000H
						MOV 		DX, 184FH
						INT 		10H
						RET
BACKGROUND4 ENDP
;----------------------------------------------
FILE_READ			PROC		NEAR
							MOV			AX, 3D02H											;OPEN FILE
							INT			21H
							JC			_ERROR
							MOV			FILE_HANDLE, AX

							MOV			AH, 3FH												;READ FILE
							MOV			BX, FILE_HANDLE
							MOV			CX, 1896
							LEA			DX, FILE_BUFFER
							INT			21H
							JC			_ERROR

							MOV			DX, 0500H											;DISPLAY FILE
							CALL 		SET_CURS
							LEA			DX, FILE_BUFFER
							CALL 		DISPLAY

							MOV 		AH, 3EH         							;CLOSE FILE
							MOV 		BX, FILE_HANDLE
							INT 		21H
							JC 			_ERROR

							RET

			 _ERROR:
			        LEA			DX, ERROR_STR									;ERROR IN FILE OPERATION
							CALL 		DISPLAY
							RET
FILE_READ			ENDP
;---------------------------------------------
LOADING 			PROC 		NEAR
							CALL 		CLS
							LEA 		DX, GHOST
							CALL 		FILE_READ

							MOV			ROW, 21
							MOV			COL, 24H

              SCRN:
                    CALL		SET_CURS
                    CMP			FLAG, 0		;check flag if done loading or not
                    JE			START
                    CMP			FLAG, 1
                    JE			MENU

              START:
                    LEA			DX, LOAD	;print loading
                    JMP			SET

              SET:
                    CALL		SET_SCRN	;loading bar
                    CMP			FLAG, 1		;exit if complete
                    JE			BACK
                    MOV			FLAG, 1		;reset screen if complete
                    JMP			SCRN

              MENU:
                    CALL		SET_CURS	;display if done loading
                    LEA			DX, COMP
                    CALL		DISPLAY

				BACK:
				      MOV			AH, 00H		;get input
							INT			16H
							RET
LOADING 	    ENDP
;--------------------------------------------------
DISP_HOWTO		PROC		NEAR
							MOV 		ROW, 0
							MOV 		COL, 0
							CALL 		SET_CURS
							CALL		CLS
							LEA			DX, HOW
							CALL		FILE_READ
							MOV			AH, 00H		;get any key input
							INT			16H
							JMP    DISP_HOME
					    RET
DISP_HOWTO		ENDP
;-----------------------------------------
DISP_HOME			PROC		NEAR												;DISPLAY MENU SCREEN
							MOV 		ROW, 0
							MOV 		COL, 0
							CALL 		SET_CURS
							CALL 		CLS
							LEA 		DX, HOME
							CALL 		FILE_READ
							JMP 		MENU_CH
							RET
DISP_HOME			ENDP
;--------------------------------------------------
MENU_CH				PROC	 	NEAR

							MOV			ROW, 22
							MOV			COL, 15
							CALL		SET_CURS
							LEA			DX, ARROW
							CALL		DISPLAY

				CHOOSE:
				      MOV			AH, 00H		;get input
							INT			16H
							CMP 		AL, 0DH 	;ENTER
							JE			CHOICE
							CMP			AH, 4BH		;LEFT
							JE			LEFT
							CMP			AH, 4DH		;RIGHT
							JE			RIGHT

							JMP			CHOOSE

				RIGHT:
				      CALL    BEEP_1
				      CMP			COL, 49		;IF RIGHT KEY
							JE			CHOOSE
							CALL		SET_CURS
							LEA			DX, SPACE
							CALL 		DISPLAY
							ADD			COL, 17
							CALL		DISP_ARR

				LEFT:
				      CALL    BEEP_1
				      CMP			COL, 15 	;IF LEFT KEY
							JE			CHOOSE
							CALL		SET_CURS
							LEA			DX, SPACE
							CALL 		DISPLAY
							SUB			COL, 17

				DISP_ARR:
				      CALL		SET_CURS	;DISPLAY ARROW
							LEA			DX, ARROW
							CALL		DISPLAY

							JMP			CHOOSE

				CHOICE:
				      CMP 		COL, 15		;START GAME
							JE			START_GAME
							CMP 		COL, 32
							JE			HOW_PG
							CMP 		COL, 49
							JE			FIN
							JMP 		CHOOSE

				HOW_PG:
				      CALL    BEEP_2
              CALL    DISP_HOWTO
              RET
				FIN:
				      CALL    BEEP_2
				      CALL		EXIT	;EXIT GAME
				      RET
        START_GAME:
              CALL    BEEP_2
              CALL    THE_LOOP
              RET
        CALL_HOWTO:


MENU_CH				ENDP
;--------------------------------------------------
SET_SCRN			PROC		NEAR
							CALL		DISPLAY
							LEA			DX, INIT	;print initial bar
							CALL 		DISPLAY
							MOV			CX, 60		;set counter

				PRGRS:
				      CMP			FLAG, 1
							JE			SKIP		;skip delay if complete
							CALL 		DELAY
				SKIP:
				      LEA			DX, BAR		;display more bars
							CALL		DISPLAY
							LOOP		PRGRS

							RET
SET_SCRN			ENDP
;------------------------------------------------------------
DISPLAY 			PROC		NEAR
							MOV			AH, 09H
							INT			21H
							RET
DISPLAY				ENDP
;------------------------------------------------------------
SET_CURS 			PROC		NEAR
							MOV			AH, 02H
							MOV			BH, 00
							MOV			DH, ROW
							MOV			DL, COL
							INT			10H
							RET
SET_CURS 			ENDP
;------------------------------------------------------------
CLS 					PROC		NEAR
							MOV			AX, 0600H
							MOV			BH, 07H
							MOV			CX, 0000H
							MOV			DX, 184FH
							INT			10H
							RET
CLS 					ENDP
;-----------------------------------------------
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
;------------------------------------------------------------
DISP_MENU	PROC	NEAR
			ADD		ROWD, 1H
			CALL	SET_CURSD
			LEA		DX, MENU1
			CALL	DISPLAY
			ADD		ROWD, 1H
			CALL	SET_CURSD
			LEA		DX, MENU2
			CALL	DISPLAY
			ADD		ROWD, 1H
			CALL	SET_CURSD
			LEA		DX, MENU3
			CALL	DISPLAY
			ADD		ROWD, 1H
			CALL	SET_CURSD
			LEA		DX, MENU4
			CALL	DISPLAY
			ADD		ROWD, 1H
			CALL	SET_CURSD
			LEA		DX, MENU5
			CALL	DISPLAY
			ADD		ROWD, 1H
			CALL	SET_CURSD
			LEA		DX, MENU6
			CALL	DISPLAY
			ADD		ROWD, 1H
			CALL	SET_CURSD
			LEA		DX, MENU7
			CALL	DISPLAY
			ADD		ROWD, 1H
			CALL	SET_CURSD
			LEA		DX, MENU8
			CALL	DISPLAY
			ADD		ROWD, 1H
			CALL	SET_CURSD
      CMP   LENGTH1, 0
      JE    P2_WINS
      CMP   LENGTH2, 0
      JE    P1_WINS
  P1_WINS:
      MOV 	  AH, 09H
			LEA 	  DX, PROMPT_1
			INT 	  21H
			JMP     JUMP_HERE
  P2_WINS:
      MOV 	  AH, 09H
			LEA 	  DX, PROMPT_2
			INT 	  21H

  JUMP_HERE:
			CALL	DISPLAY
			ADD		ROWD, 1H
			CALL	SET_CURSD
			LEA		DX, MENU10
			CALL	DISPLAY
			ADD		ROWD, 1H
			CALL	SET_CURSD
			LEA		DX, MENU11
			CALL	DISPLAY
			ADD		ROWD, 1H
			CALL	SET_CURSD
			LEA		DX, MENU12
			CALL	DISPLAY
			ADD		ROWD, 1H
			CALL	SET_CURSD
			LEA		DX, MENU12
			CALL	DISPLAY
		  ADD		ROWD, 1H
			CALL	SET_CURSD
			CALL  COMBI1
			LEA		DX, MENU13
			CALL	DISPLAY
			;CALL  COMBI1
	ASK_INPUT:
			MOV   AH, 00H
			INT   16H
      CMP   AL, 0DH
      JE    RET_A
      JMP   ASK_INPUT
			RET

  RET_A:
      CALL  RESET_DATA
      CALL  GAME_LOOP
      RET
DISP_MENU	ENDP
;------------------------------------------------------------
SET_CURSD PROC	NEAR
			MOV		AH, 02H
			MOV		BH, 00
			MOV		DH, ROWD
			MOV		DL, COLD
			INT		10H
			RET
SET_CURSD ENDP
;------------------------------------------------------------
RESET_DATA   PROC    NEAR                                                ;RESETS the data for next game
             RET
RESET_DATA   ENDP
;--------------------------------------------------------------
MUSIC       PROC   NEAR                                             ;PRODUCES music for the gameover screen
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
;--------------------------------------------------------------
COMBI1     PROC   NEAR                                        ;MUSIC COMBINATION 1
		       MOV   AX, 2152
					 MOV   BEEPCX, 500
					 CALL  MUSIC
					 MOV   AX, 3403
					 MOV   BEEPCX, 10
					 CALL  MUSIC
					 MOV   AX, 3224
					 MOV   BEEPCX, 1
					 CALL  MUSIC
					 MOV   AX, 3416
					 MOV   BEEPCX, 10
					 CALL  MUSIC
					 MOV   AX, 3834
					 MOV   BEEPCX, 10
					 CALL  MUSIC
					 RET
COMBI1     ENDP
;--------------------------------------------------------------
COMBI2    PROC    NEAR                                       ;MUSIC COMBINATION 2
				  MOV     AX, 3043
				  MOV     BEEPCX, 1
				  CALL    MUSIC
				  RET
COMBI2    ENDP
;--------------------------------------------------------------
          END 				 MAIN
