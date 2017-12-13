TITLE     MOV IT(EXE)
          .MODEL SMALL
;---------------------------------------------------------------------
          .STACK 200H
;---------------------------------------------------------------------
.DATA
  ROW               DB 0
  COL               DB 0

  FLAG              DB 0

  CHECKER           DB 0
  TEMP              DB ?

  HOME	      DB	 'screen.txt', 0
  LOADFile 	  DB 	 'load.txt', 0
  HowToPlay   DB 	 'htp.txt', 0

  FILE_HANDLE	DW	 ?
  ERROR_STR	  DB	 'Error READING!!$'
  FILE_BUFFER	DB 	  1896 DUP('$')
  LOAD	      DB	 'Moving...$'
  COMPLETE	  DB	 'START!....$'
  INIT	      DB	  0ah, 0dh, 20 DUP(219), '$'
  BAR		      DB	  219, '$'
  ARROW	      DB	  175, '$'
  EMPTY	      DB	  '$'
  SPACE   		DB   ' ', '$'                      ;Character for clearing
  ROWD	 	    DB		6H, '$'
  COLD	    	DB		0

  BEEPCX      DW   ?
  BEEPBX      DB   ?
;---------------------------------------------------------------------
.CODE

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
;---------------------------------------------------------------------
HIDE_CURSOR PROC    NEAR
			      MOV     CX, 2000H
			      MOV     AH, 01H
			      INT     10H
			      RET
HIDE_CURSOR ENDP
;---------------------------------------------------------------------
CLS0 					PROC		NEAR
							MOV			AX, 0600H
							MOV			BH, 0BH
							MOV			CX, 0000H
							MOV			DX, 184FH
							INT			10H
							RET
CLS0 					ENDP
;---------------------------------------------------------------------
LOADING 			PROC 		NEAR
							CALL 		CLS0
							LEA 		DX, LOADFile
							CALL 		FILE_READ

							MOV			ROW, 22
							MOV			COL, 23H
				SCRN:
				      CALL		SET_CURS
							CMP			FLAG, 0		;checks flag if its done loading
							JE			START
							CMP			FLAG, 1
							JE			MENU

				START:
				      LEA			DX, LOAD	;prints loading
							JMP			SET

				SET:
				      CALL		SET_SCRN	;loading bar
							CMP			FLAG, 1		;exits after it has completed
							JE			BACK
							MOV			FLAG, 1		;resets the screen after it has completed
							JMP			SCRN

				MENU:
				      CALL		SET_CURS	;displays menu after loading
							LEA			DX, COMPLETE
							CALL		PRINT

				BACK:
				      MOV			AH, 00H		;get input
							INT			16H
							RET
LOADING 	    ENDP
;---------------------------------------------------------------------
COMPARE     PROC    NEAR

            CMP     TEMP, 4DH   ;IF RED
            JE      UP
            CMP     TEMP, 4BH   ;IF CYAN
            JE      DOWN
            CMP     TEMP, 48H   ;IF BLUE
            JE      LEFT
            CMP     TEMP, 50H   ;IF GREEN
            JE      RIGHT
            CMP     TEMP, 01
            JE      QUIT

            UP:
              CMP     CHECKER, 4DH
              JE      LEAVE
              JMP     LEAVE_STILL

            DOWN:
              CMP     CHECKER, 4BH
              JE      LEAVE
              JMP     LEAVE_STILL

            LEFT:
              CMP     CHECKER, 48H
              JE      LEAVE
              JMP     LEAVE_STILL

            RIGHT:
              CMP     CHECKER, 50H
              JE      LEAVE
              JMP     LEAVE_STILL

            LEAVE_STILL:
              MOV     FLAG, 0
              RET

            LEAVE:
              MOV   FLAG, 1
              RET

            QUIT:
              CALL  EXIT
COMPARE     ENDP
;---------------------------------------------------------------------
DISP_HOWTO		PROC		NEAR
							MOV 		ROW, 0
							MOV 		COL, 0
							CALL 		SET_CURS
							CALL		CLS0
							LEA			DX, HOWTOPLAY
							CALL		FILE_READ
							MOV			AH, 00H		;get any key input
							INT			16H
              CALL    CLS0
							JMP    DISP_HOME
					    RET
DISP_HOWTO		ENDP
;-----------------------------------------
DISP_HOME			PROC		NEAR												;DISPLAY MENU SCREEN
							MOV 		ROW, 0
							MOV 		COL, 0
							CALL 		SET_CURS
							CALL 		CLS0
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
							CALL		PRINT

				CHOOSE:
				      MOV			AH, 00H		;get input
							INT			16H
							CMP 		AL, 0DH 	;ENTER
							JE			CHOICE
							CMP			AH, 4BH		;LEFT
							JE			LEFT1
							CMP			AH, 4DH		;RIGHT
							JE			RIGHT1

							JMP			CHOOSE

				RIGHT1:
				      CALL    BEEP_1
				      CMP			COL, 49		;IF RIGHT KEY
							JE			CHOOSE
							CALL		SET_CURS
							LEA			DX, SPACE
							CALL 		PRINT
							ADD			COL, 17
							CALL		DISP_ARR

				LEFT1:
				      CALL    BEEP_1
				      CMP			COL, 15 	;IF LEFT KEY
							JE			CHOOSE
							CALL		SET_CURS
							LEA			DX, SPACE
							CALL 		PRINT
							SUB			COL, 17

				DISP_ARR:
				      CALL		SET_CURS	;DISPLAY ARROW
							LEA			DX, ARROW
							CALL		PRINT

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
              CALL    LOOP_GAME
              RET
        CALL_HOWTO:
MENU_CH				ENDP
;--------------------------------------------------
LOOP_GAME     PROC    NEAR

            ITERATE:
              MOV     BH, 0BH
              CALL    CLS
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
;--------------------------------------------------
SET_SCRN			PROC		NEAR
							CALL		PRINT
							LEA			DX, INIT	;print initial bar
							CALL 		PRINT
							MOV			CX, 60		;set counter

				PRGRS:
				      CMP			FLAG, 1
							JE			SKIP		;skip delay if complete
							CALL 		DELAY
				SKIP:
				      LEA			DX, BAR		;PRINT more bars
							CALL		PRINT
							LOOP		PRGRS

							RET
SET_SCRN			ENDP
;---------------------------------------------------------------------
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
;---------------------------------------------------------------------
SET_CURS 			PROC		NEAR
							MOV			AH, 02H
							MOV			BH, 00
							MOV			DH, ROW
							MOV			DL, COL
							INT			10H
							RET
SET_CURS 			ENDP
;---------------------------------------------------------------------
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
;---------------------------------------------------------------------
CLS         PROC
            MOV     AX, 0600H
            MOV     CX, 0000H
            MOV     DX, 184FH
            INT     10H
            RET
CLS         ENDP
;---------------------------------------------------------------------
CLS2         PROC
            MOV     AX, 0600H
            MOV     CX, 0614H
            MOV     DX, 123CH
            INT     10H
            RET
CLS2         ENDP
;---------------------------------------------------------------------
SET_CURSOR  PROC
            MOV			AH, 02H
            MOV			BH, 00
            MOV			DL, ROW
            MOV			DH, COL
            INT			10H
            RET
SET_CURSOR  ENDP
;---------------------------------------------------------------------
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
							CALL 		PRINT

							MOV 		AH, 3EH         							;CLOSE FILE
							MOV 		BX, FILE_HANDLE
							INT 		21H
							JC 			_ERROR

							RET

			 _ERROR:
			        LEA			DX, ERROR_STR									;ERROR IN FILE OPERATION
							CALL 		PRINT
							RET
				BK:
				      RET
FILE_READ			ENDP
;---------------------------------------------------------------------
PRINT       PROC
            MOV     AH, 09
            INT     21H
            RET
PRINT       ENDP
;---------------------------------------------------------------------
BEEP_1       PROC    NEAR        ;high pitch beep sound for menu option

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
;--------------------------------------------------------------
BEEP_2       PROC     NEAR           ;beep for enter
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
;--------------------------------------------------------------
MUSIC       PROC   NEAR                 ;PRODUCES music for the gameover screen
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
;---------------------------------------------------------------------
GET_KEY	    PROC	NEAR

          	MOV		AH, 00H
          	INT		16H

          	MOV		TEMP, AH

          	RET
GET_KEY 	  ENDP
;---------------------------------------------------------------------
END
