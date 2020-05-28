
CSKB0 xDATA 21h				; klawiatura matrycowa: klawisze 0...7
CSKB1 xDATA 22h				; klawiatura matrycowa: klawisze 8...

LCDWC xDATA 0FF80h			; HD44780 - wpis rozkazów
LCDWD xDATA 0FF81h			; HD44780 - wpis danyc
LCDRC xDATA 0FF82h			; HD44780 - odczyt stanu
LCDRD xDATA 0FF83h			; HD44780 - odczyt danyh

STRING DATA 042h			; offset napisu do wyswietlenia przez LCD

STL DATA 055h 				; informacje o stanie programu młodszy bajt
STH DATA 056h 				; informacje o stanie programu starszy bajt

T0_VAL_INIT EQU 65535 - 9215
TH0_INIT EQU T0_VAL_INIT / 256
TL0_INIT EQU T0_VAL_INIT MOD 256
TIMER_COUNTER DATA 045h	

LEFT_KEY 	DATA 049h 		; CSKBD1 bit 2
RIGHT_KEY	DATA 050h		; CSKBD1 bit 3
UP_KEY		DATA 051h		; CSKBD1 bit 4
DOWN_KEY	DATA 052h		; CSKBD1 bit 5
ESC_KEY		DATA 053h		; CSKBD1 bit 6
ENTER_KEY	DATA 054h 		; CSKBD1 bit 7

STIME DATA 070h				; czas pracy sekundy
MTIME DATA 071h				; czas pracy minuty
HTIME DATA 072h				; czas pracy godziny

CHAR0 DATA 073h
CHAR1 DATA 074h
CHAR2 DATA 075h
CHARP DATA 076h

;---------------------------------------------------------------------------
;                       S T A R T    P R O G R A M U
;---------------------------------------------------------------------------
	ORG 	0000h
_RESET:
	LJMP 	_INIT
	ORG 	000Bh
_OVRFL:
	MOV 	TH0, #TH0_INIT
	INC 	TIMER_COUNTER
	RETI
	ORG 	0100h
;---------------------------------------------------------------------------
;                        I N I C J A L I Z A C J A 
;---------------------------------------------------------------------------
_INIT:
	CLR		C

	MOV 	SCON, #01010000b 					; M0=0  M1=1  M2=0  REN=1  TB8=0  RB8=0  TI=0  RI=0
	ANL		TMOD, #00101111b
	ORL 	TMOD, #00100000b

	MOV 	TL1, #0FDh
	MOV 	TH1, #0FDh
	ANL 	PCON, #01111111b
	CLR 	TF1
	SETB 	TR1

	MOV 	STIME, #00d
	MOV 	MTIME, #00d
	MOV 	HTIME, #00d

	MOV 	CHAR0, #0d
	MOV 	CHAR1, #1d
	MOV 	CHAR2, #2d
	MOV 	CHARP, #1d

	MOV 	TIMER_COUNTER, #0d					; zainicjalizowanie licznika programowego
	MOV 	TMOD, #00000001b
	MOV 	TH0, #TH0_INIT
	MOV 	TL0, #TL0_INIT
	SETB 	EA
	SETB 	ET0

	CLR 	TF0									; flaga przepelnienia - wyczysc	
	SETB 	TR0

	CALL 	_LCD_INIT
	
	CALL 	_GOTO_SETTINGS_EDIT_MSG_ENABLE
;---------------------------------------------------------------------------
;                        P E T L A    G L O W N A
;---------------------------------------------------------------------------
_LOOP:
	CALL 	_KBD_HANDLE

	;--------------------------------;
	MOV 	A, STL
	ANL 	A, #00000001b
	JNZ 	_MSG_LJMP
	LJMP 	_MSG_LJMP_END
	_MSG_LJMP:
		LJMP 	_MSG
	_MSG_LJMP_END:
	;--------------------------------;

	;--------------------------------;
	MOV 	A, STL
	ANL 	A, #00000010b
	JNZ 	_SETTINGS_LJMP
	LJMP 	_SETTINGS_LJMP_END
	_SETTINGS_LJMP:
		LJMP 	_SETTINGS
	_SETTINGS_LJMP_END:
	;--------------------------------;

	;--------------------------------;
	MOV 	A, STL
	ANL 	A, #00000100b
	JNZ 	_TEST_LMJP
	LJMP 	_TEST_LMJP_END
	_TEST_LMJP:
		LJMP 	_TEST
	_TEST_LMJP_END:
	;--------------------------------;

	;--------------------------------;
	MOV 	A, STL
	ANL 	A, #00001000b
	JNZ 	_TEST_BUZZER_LMJP
	LJMP 	_TEST_BUZZER_LMJP_END
	_TEST_BUZZER_LMJP:
		LJMP 	_TEST_BUZZER
	_TEST_BUZZER_LMJP_END:
	;--------------------------------;

	;--------------------------------;
	MOV 	A, STL
	ANL 	A, #00010000b
	JNZ 	_TEST_LED_LMJP
	LJMP 	_TEST_LED_LMJP_END
	_TEST_LED_LMJP:
		LJMP 	_TEST_LED
	_TEST_LED_LMJP_END:
	;--------------------------------;

	;--------------------------------;
	MOV 	A, STL
	ANL 	A, #00100000b
	JNZ 	_SETTINGS_UPTIME_LMJP
	LJMP 	_SETTINGS_UPTIME_LMJP_END
	_SETTINGS_UPTIME_LMJP:
		LJMP 	_SETTINGS_UPTIME
	_SETTINGS_UPTIME_LMJP_END:
	;--------------------------------;

	;--------------------------------;
	MOV 	A, STL
	ANL 	A, #01000000b
	JNZ 	_MSG_SEND_LMJP
	LJMP 	_MSG_SEND_LMJP_END
	_MSG_SEND_LMJP:
		LJMP 	_MSG_SEND
	_MSG_SEND_LMJP_END:
	;--------------------------------;

	;--------------------------------;
	MOV 	A, STL
	ANL 	A, #10000000b
	JNZ 	_SETTINGS_EDIT_MSG_LMJP
	LJMP 	_SETTINGS_EDIT_MSG_END
	_SETTINGS_EDIT_MSG_LMJP:
		LJMP 	_SETTINGS_EDIT_MSG
	_SETTINGS_EDIT_MSG_END:
	;--------------------------------;

	;--------------------------------;
	MOV 	A, STH
	ANL 	A, #00000001b
	JNZ 	_SETTINGS_EDIT_MSG_ENABLE_LMJP
	LJMP 	_SETTINGS_EDIT_MSG_ENABLE_END
	_SETTINGS_EDIT_MSG_ENABLE_LMJP:
		LJMP 	_SETTINGS_EDIT_MSG_ENABLE
	_SETTINGS_EDIT_MSG_ENABLE_END:
	;--------------------------------;

_LOOP_TIMER:
	MOV 	A, #99d								; obsługa licznika programowego timera
	CLR 	C
	SUBB 	A, TIMER_COUNTER
	JNC 	_LOOP
	CLR 	C
	MOV 	A, TIMER_COUNTER
	SUBB 	A, #100d
	MOV 	TIMER_COUNTER, A
	; ----- zdarzenia co 1 sek ------;
	INC 	STIME
	MOV 	A, STIME
	CJNE 	A, #60, _LOOP_TIMER_LJMP
	MOV 	STIME, #00d
	INC 	MTIME
	MOV 	A, MTIME
	CJNE 	A, #60, _LOOP_TIMER_LJMP
	MOV 	MTIME, #00d
	INC 	HTIME
	_LOOP_TIMER_LJMP:
		LJMP 	_LOOP
;---------------------------------------------------------------------------
;                                    M S G
;---------------------------------------------------------------------------
_MSG:
	;----------[ ENTER KEY ]-----------;
	MOV 	A, ENTER_KEY
	JNZ 	_MSG_ENTER_PRESSED
	LJMP 	_MSG_ENTER_NOT_RESSED

	_MSG_ENTER_PRESSED:
		CALL 	_GOTO_MSG_SEND
		LJMP	_MSG_ENTER_END
	_MSG_ENTER_NOT_RESSED:
		LJMP	_MSG_ENTER_END
	_MSG_ENTER_END:
	;----------------------------------;

	;------------[ UP KEY ]------------;
	MOV 	A, UP_KEY
	JNZ 	_MSG_UP_PRESSED
	LJMP 	_MSG_UP_NOT_RESSED

	_MSG_UP_PRESSED:
		CALL 	_GOTO_TEST
		LJMP	_MSG_UP_END
	_MSG_UP_NOT_RESSED:
		LJMP	_MSG_UP_END
	_MSG_UP_END:
	;----------------------------------;
	
	;-----------[ DOWN KEY ]-----------;
	MOV 	A, DOWN_KEY
	JNZ 	_MSG_DOWN_PRESSED
	LJMP 	_MSG_DOWN_NOT_RESSED

	_MSG_DOWN_PRESSED:
		CALL 	_GOTO_SETTINGS
		LJMP	_MSG_DOWN_END
	_MSG_DOWN_NOT_RESSED:
		LJMP	_MSG_DOWN_END
	_MSG_DOWN_END:
	;----------------------------------;
	LJMP	_LOOP_TIMER
;---------------------------------------------------------------------------
;                            M S G  /  S E N D
;---------------------------------------------------------------------------
_MSG_SEND:
	;----------[ ENTER KEY ]-----------;
	MOV 	A, ENTER_KEY
	JNZ 	_MSG_SEND_ENTER_PRESSED
	LJMP 	_MSG_SEND_ENTER_NOT_RESSED

	_MSG_SEND_ENTER_PRESSED:
		MOV 	SBUF, #32
		LJMP	_MSG_SEND_ENTER_END
	_MSG_SEND_ENTER_NOT_RESSED:
		LJMP	_MSG_SEND_ENTER_END
	_MSG_SEND_ENTER_END:
	;----------------------------------;

	;------------[ ESC KEY ]-----------;
	MOV 	A, ESC_KEY
	JNZ 	_MSG_SEND_ESC_PRESSED
	LJMP 	_MSG_SEND_ESC_NOT_RESSED

	_MSG_SEND_ESC_PRESSED:
		CALL 	_GOTO_MSG
		LJMP	_MSG_SEND_ESC_END
	_MSG_SEND_ESC_NOT_RESSED:
		LJMP	_MSG_SEND_ESC_END
	_MSG_SEND_ESC_END:
	;----------------------------------;

	LJMP	_LOOP_TIMER
;---------------------------------------------------------------------------
;                              S E T T I N G S
;---------------------------------------------------------------------------
_SETTINGS:
	;------------[ UP KEY ]------------;
	MOV 	A, UP_KEY
	JNZ 	_SETTINGS_UP_PRESSED
	LJMP 	_SETTINGS_UP_NOT_RESSED

	_SETTINGS_UP_PRESSED:
		CALL 	_GOTO_MSG
		LJMP	_SETTINGS_UP_END
	_SETTINGS_UP_NOT_RESSED:
		LJMP	_SETTINGS_UP_END
	_SETTINGS_UP_END:
	;----------------------------------;

	
	;-----------[ DOWN KEY ]-----------;
	MOV 	A, DOWN_KEY
	JNZ 	_SETTINGS_DOWN_PRESSED
	LJMP 	_SETTINGS_DOWN_NOT_RESSED

	_SETTINGS_DOWN_PRESSED:
		CALL 	_GOTO_TEST
		LJMP	_SETTINGS_DOWN_END
	_SETTINGS_DOWN_NOT_RESSED:
		NOP
		LJMP	_SETTINGS_DOWN_END
	_SETTINGS_DOWN_END:
	;----------------------------------;

	;----------[ ENTER KEY ]-----------;
	MOV 	A, ENTER_KEY
	JNZ 	_SETTINGS_ENTER_PRESSED
	LJMP 	_SETTINGS_ENTER_NOT_RESSED

	_SETTINGS_ENTER_PRESSED:
		CALL 	_GOTO_SETTINGS_UPTIME
		LJMP	_SETTINGS_ENTER_END
	_SETTINGS_ENTER_NOT_RESSED:
		LJMP	_SETTINGS_ENTER_END
	_SETTINGS_ENTER_END:
	;----------------------------------;

	LJMP	_LOOP_TIMER
;---------------------------------------------------------------------------
;                 S E T T I N G S  /  E D I T _ M S G
;---------------------------------------------------------------------------
_SETTINGS_EDIT_MSG:
	;----------[ ENTER KEY ]-----------;
	MOV 	A, ENTER_KEY
	JNZ 	_SETTINGS_EDIT_MSG_ENTER_PRESSED
	LJMP 	_SETTINGS_EDIT_MSG_ENTER_NOT_RESSED

	_SETTINGS_EDIT_MSG_ENTER_PRESSED:
		CALL 	_GOTO_SETTINGS_EDIT_MSG_ENABLE
		LJMP	_SETTINGS_EDIT_MSG_ENTER_END
	_SETTINGS_EDIT_MSG_ENTER_NOT_RESSED:
		LJMP	_SETTINGS_EDIT_MSG_ENTER_END
	_SETTINGS_EDIT_MSG_ENTER_END:
	;----------------------------------;

	;------------[ ESC KEY ]-----------;
	MOV 	A, ESC_KEY
	JNZ 	_SETTINGS_EDIT_MSG_ESC_PRESSED
	LJMP 	_SETTINGS_EDIT_MSG_ESC_NOT_RESSED

	_SETTINGS_EDIT_MSG_ESC_PRESSED:
		CALL 	_GOTO_SETTINGS
		LJMP	_SETTINGS_EDIT_MSG_ESC_END
	_SETTINGS_EDIT_MSG_ESC_NOT_RESSED:
		LJMP	_SETTINGS_EDIT_MSG_ESC_END
	_SETTINGS_EDIT_MSG_ESC_END:
	;----------------------------------;

	;------------[ UP KEY ]------------;
	MOV 	A, UP_KEY
	JNZ 	_SETTINGS_EDIT_MSG_UP_PRESSED
	LJMP 	_SETTINGS_EDIT_MSG_UP_NOT_RESSED

	_SETTINGS_EDIT_MSG_UP_PRESSED:
		CALL 	_GOTO_SETTINGS_UPTIME
		LJMP	_SETTINGS_EDIT_MSG_UP_END
	_SETTINGS_EDIT_MSG_UP_NOT_RESSED:
		LJMP	_SETTINGS_EDIT_MSG_UP_END
	_SETTINGS_EDIT_MSG_UP_END:
	;----------------------------------;
	
	;-----------[ DOWN KEY ]-----------;
	MOV 	A, DOWN_KEY
	JNZ 	_SETTINGS_EDIT_MSG_DOWN_PRESSED
	LJMP 	_SETTINGS_EDIT_MSG_DOWN_NOT_RESSED

	_SETTINGS_EDIT_MSG_DOWN_PRESSED:
		CALL 	_GOTO_SETTINGS_UPTIME
		LJMP	_SETTINGS_EDIT_MSG_DOWN_END
	_SETTINGS_EDIT_MSG_DOWN_NOT_RESSED:
		LJMP	_SETTINGS_EDIT_MSG_DOWN_END
	_SETTINGS_EDIT_MSG_DOWN_END:
	;----------------------------------;

	LJMP _LOOP_TIMER
;---------------------------------------------------------------------------
;            S E T T I N G S  /  E D I T _ M S G  /  E N A B L E
;---------------------------------------------------------------------------
_SETTINGS_EDIT_MSG_ENABLE:
	;-----------[ DOWN KEY ]-----------;
	MOV 	A, DOWN_KEY
	JNZ 	_EDIT_MSG_ENABLE_DOWN_PRESSED
	LJMP 	_EDIT_MSG_ENABLE_DOWN_NOT_RESSED

	_EDIT_MSG_ENABLE_DOWN_PRESSED:
		MOV 	A, CHARP
		CJNE 	A, #0, _DOWN_CHAR_IS_NOT_0
		LJMP 	_DOWN_CHAR_IS_0
		_DOWN_CHAR_IS_NOT_0:
			CJNE 	A, #1, _DOWN_CHAR_IS_NOT_1
			LJMP 	_DOWN_CHAR_IS_1
		_DOWN_CHAR_IS_NOT_1:
			CJNE 	A, #2, _DOWN_CHAR_IS_NOT_2
			LJMP 	_DOWN_CHAR_IS_2
		_DOWN_CHAR_IS_NOT_2:
			_DOWN_CHAR_IS_0:
				DEC 	CHAR0
				CALL 	_LCD_EDIT_MSG_DISPLAY
				LJMP	_EDIT_MSG_ENABLE_DOWN_END

			_DOWN_CHAR_IS_1:
				DEC 	CHAR1
				CALL 	_LCD_EDIT_MSG_DISPLAY
				LJMP	_EDIT_MSG_ENABLE_DOWN_END

			_DOWN_CHAR_IS_2:
				DEC 	CHAR2
				CALL 	_LCD_EDIT_MSG_DISPLAY
				LJMP	_EDIT_MSG_ENABLE_DOWN_END

	_EDIT_MSG_ENABLE_DOWN_NOT_RESSED:
		LJMP	_EDIT_MSG_ENABLE_DOWN_END
	_EDIT_MSG_ENABLE_DOWN_END:
	;----------------------------------;

	;------------[ UP KEY ]------------;
	MOV 	A, UP_KEY
	JNZ 	_EDIT_MSG_ENABLE_UP_PRESSED
	LJMP 	_EDIT_MSG_ENABLE_UP_NOT_RESSED

	_EDIT_MSG_ENABLE_UP_PRESSED:
		MOV 	A, CHARP
		CJNE 	A, #0, _UP_CHAR_IS_NOT_0
		LJMP 	_UP_CHAR_IS_0
		_UP_CHAR_IS_NOT_0:
			CJNE 	A, #1, _UP_CHAR_IS_NOT_1
			LJMP 	_UP_CHAR_IS_1
		_UP_CHAR_IS_NOT_1:
			CJNE 	A, #2, _UP_CHAR_IS_NOT_2
			LJMP 	_UP_CHAR_IS_2
		_UP_CHAR_IS_NOT_2:
			_UP_CHAR_IS_0:
				INC 	CHAR0
				CALL 	_LCD_EDIT_MSG_DISPLAY
				LJMP	_EDIT_MSG_ENABLE_UP_END

			_UP_CHAR_IS_1:
				INC 	CHAR1
				CALL 	_LCD_EDIT_MSG_DISPLAY
				LJMP	_EDIT_MSG_ENABLE_UP_END

			_UP_CHAR_IS_2:
				INC 	CHAR2
				CALL 	_LCD_EDIT_MSG_DISPLAY
				LJMP	_EDIT_MSG_ENABLE_UP_END

	_EDIT_MSG_ENABLE_UP_NOT_RESSED:
		LJMP	_EDIT_MSG_ENABLE_UP_END
	_EDIT_MSG_ENABLE_UP_END:
	;----------------------------------;

	;----------[ RIGHT KEY ]-----------;
	MOV 	A, RIGHT_KEY
	JNZ 	_EDIT_MSG_ENABLE_RIGHT_PRESSED
	LJMP 	_EDIT_MSG_ENABLE_RIGHT_NOT_RESSED

	_EDIT_MSG_ENABLE_RIGHT_PRESSED:
		MOV 	A, CHARP
		CJNE 	A, #0, _EDIT_MSG_ENABLE_RIGHT_DEC
		LJMP	_EDIT_MSG_ENABLE_RIGHT_END
		_EDIT_MSG_ENABLE_RIGHT_DEC:
		DEC 	CHARP
		CALL 	_LCD_EDIT_MSG_DISPLAY
		LJMP	_EDIT_MSG_ENABLE_RIGHT_END
	_EDIT_MSG_ENABLE_RIGHT_NOT_RESSED:
		LJMP	_EDIT_MSG_ENABLE_RIGHT_END
	_EDIT_MSG_ENABLE_RIGHT_END:
	;----------------------------------;

	;----------[ LEFT KEY ]-----------;
	MOV 	A, LEFT_KEY
	JNZ 	_EDIT_MSG_ENABLE_LEFT_PRESSED
	LJMP 	_EDIT_MSG_ENABLE_LEFT_NOT_RESSED

	_EDIT_MSG_ENABLE_LEFT_PRESSED:
		MOV 	A, CHARP
		CJNE 	A, #2, _EDIT_MSG_ENABLE_LEFT_INC
		LJMP 	_EDIT_MSG_ENABLE_LEFT_END
		_EDIT_MSG_ENABLE_LEFT_INC:
		INC 	CHARP
		CALL 	_LCD_EDIT_MSG_DISPLAY
		LJMP	_EDIT_MSG_ENABLE_LEFT_END
	_EDIT_MSG_ENABLE_LEFT_NOT_RESSED:
		LJMP	_EDIT_MSG_ENABLE_LEFT_END
	_EDIT_MSG_ENABLE_LEFT_END:
	;----------------------------------;

	;------------[ ESC KEY ]-----------;
	MOV 	A, ESC_KEY
	JNZ 	_SETTINGS_EDIT_MSG_ENABLE_ESC_PRESSED
	LJMP 	_SETTINGS_EDIT_MSG_ENABLE_ESC_NOT_RESSED

	_SETTINGS_EDIT_MSG_ENABLE_ESC_PRESSED:
		CALL 	_GOTO_SETTINGS_EDIT_MSG
		LJMP	_SETTINGS_EDIT_MSG_ENABLE_ESC_END
	_SETTINGS_EDIT_MSG_ENABLE_ESC_NOT_RESSED:
		LJMP	_SETTINGS_EDIT_MSG_ENABLE_ESC_END
	_SETTINGS_EDIT_MSG_ENABLE_ESC_END:
	;----------------------------------;

	LJMP _LOOP_TIMER
;---------------------------------------------------------------------------
;              W Y S W I E T L A N I E    E D I T _ M S G
;---------------------------------------------------------------------------
_LCD_EDIT_MSG_DISPLAY:
	CALL 	_LCD_CLEAR

	MOV 	A, CHARP
	CJNE	A, #2d, _CHARP2B_END
	MOV 	R7, #91d
	CALL 	_LCD_DATA_FROM_R7
	_CHARP2B_END:

	MOV 	A, CHAR2
	ADD 	A, #48d
	MOV 	R7, A
	CALL 	_LCD_DATA_FROM_R7

	MOV 	A, CHARP
	CJNE	A, #2d, _CHARP2E_END
	MOV 	R7, #93d
	CALL 	_LCD_DATA_FROM_R7
	_CHARP2E_END:

	MOV 	A, CHARP
	CJNE	A, #1d, _CHARP1B_END
	MOV 	R7, #91d
	CALL 	_LCD_DATA_FROM_R7
	_CHARP1B_END:

	MOV 	A, CHAR1
	ADD 	A, #48d
	MOV 	R7, A
	CALL 	_LCD_DATA_FROM_R7

	MOV 	A, CHARP
	CJNE	A, #1d, _CHARP1E_END
	MOV 	R7, #93d
	CALL 	_LCD_DATA_FROM_R7
	_CHARP1E_END:

	MOV 	A, CHARP
	CJNE	A, #0d, _CHARP0B_END
	MOV 	R7, #91d
	CALL 	_LCD_DATA_FROM_R7
	_CHARP0B_END:

	MOV 	A, CHAR0
	ADD 	A, #48d
	MOV 	R7, A
	CALL 	_LCD_DATA_FROM_R7

	MOV 	A, CHARP
	CJNE	A, #0d, _CHARP0E_END
	MOV 	R7, #93d
	CALL 	_LCD_DATA_FROM_R7
	_CHARP0E_END:

	RET
;---------------------------------------------------------------------------
;                   S E T T I N G S  /  U P T I M E
;---------------------------------------------------------------------------
_SETTINGS_UPTIME:
	;----------[ ENTER KEY ]-----------;
	MOV 	A, ENTER_KEY
	JNZ 	_SETTINGS_UPTIME_ENTER_PRESSED
	LJMP 	_SETTINGS_UPTIME_ENTER_NOT_RESSED

	_SETTINGS_UPTIME_ENTER_PRESSED:
		CALL 	_LCD_UPTIME_DISPLAY
		LJMP	_SETTINGS_UPTIME_ENTER_END
	_SETTINGS_UPTIME_ENTER_NOT_RESSED:
		LJMP	_SETTINGS_UPTIME_ENTER_END
	_SETTINGS_UPTIME_ENTER_END:
	;----------------------------------;

	;------------[ ESC KEY ]-----------;
	MOV 	A, ESC_KEY
	JNZ 	_SETTINGS_UPTIME_ESC_PRESSED
	LJMP 	_SETTINGS_UPTIME_ESC_NOT_RESSED

	_SETTINGS_UPTIME_ESC_PRESSED:
		CALL 	_GOTO_SETTINGS
		LJMP	_SETTINGS_UPTIME_ESC_END
	_SETTINGS_UPTIME_ESC_NOT_RESSED:
		LJMP	_SETTINGS_UPTIME_ESC_END
	_SETTINGS_UPTIME_ESC_END:
	;----------------------------------;

	;------------[ UP KEY ]------------;
	MOV 	A, UP_KEY
	JNZ 	_SETTINGS_UPTIME_UP_PRESSED
	LJMP 	_SETTINGS_UPTIME_UP_NOT_RESSED

	_SETTINGS_UPTIME_UP_PRESSED:
		CALL 	_GOTO_SETTINGS_EDIT_MSG
		LJMP	_SETTINGS_UPTIME_UP_END
	_SETTINGS_UPTIME_UP_NOT_RESSED:
		LJMP	_SETTINGS_UPTIME_UP_END
	_SETTINGS_UPTIME_UP_END:
	;----------------------------------;
	
	;-----------[ DOWN KEY ]-----------;
	MOV 	A, DOWN_KEY
	JNZ 	_SETTINGS_UPTIME_DOWN_PRESSED
	LJMP 	_SETTINGS_UPTIME_DOWN_NOT_RESSED

	_SETTINGS_UPTIME_DOWN_PRESSED:
		CALL 	_GOTO_SETTINGS_EDIT_MSG
		LJMP	_SETTINGS_UPTIME_DOWN_END
	_SETTINGS_UPTIME_DOWN_NOT_RESSED:
		LJMP	_SETTINGS_UPTIME_DOWN_END
	_SETTINGS_UPTIME_DOWN_END:
	;----------------------------------;

	LJMP	_LOOP_TIMER
;---------------------------------------------------------------------------
;                               T E S T
;---------------------------------------------------------------------------
_TEST:
	;------------[ UP KEY ]------------;
	MOV 	A, UP_KEY
	JNZ 	_TEST_UP_PRESSED
	LJMP 	_TEST_UP_NOT_RESSED

	_TEST_UP_PRESSED:
		CALL 	_GOTO_SETTINGS
		LJMP	_TEST_UP_END
	_TEST_UP_NOT_RESSED:
		LJMP	_TEST_UP_END
	_TEST_UP_END:
	;----------------------------------;

	
	;-----------[ DOWN KEY ]-----------;
	MOV 	A, DOWN_KEY
	JNZ 	_TEST_DOWN_PRESSED
	LJMP 	_TEST_DOWN_NOT_RESSED

	_TEST_DOWN_PRESSED:
		CALL 	_GOTO_MSG
		LJMP	_TEST_DOWN_END
	_TEST_DOWN_NOT_RESSED:
		LJMP	_TEST_DOWN_END
	_TEST_DOWN_END:
	;----------------------------------;

	;----------[ ENTER KEY ]-----------;
	MOV 	A, ENTER_KEY
	JNZ 	_TEST_ENTER_PRESSED
	LJMP 	_TEST_ENTER_NOT_RESSED

	_TEST_ENTER_PRESSED:
		CALL 	_GOTO_TEST_BUZZER
		LJMP	_TEST_ENTER_END
	_TEST_ENTER_NOT_RESSED:
		LJMP	_TEST_ENTER_END
	_TEST_ENTER_END:
	;----------------------------------;

	LJMP	_LOOP_TIMER
;---------------------------------------------------------------------------
;                         T E S T  /  B U Z Z E R
;---------------------------------------------------------------------------
_TEST_BUZZER:
	;------------[ UP KEY ]------------;
	MOV 	A, UP_KEY
	JNZ 	_TEST_BUZZER_UP_PRESSED
	LJMP 	_TEST_BUZZER_UP_NOT_RESSED

	_TEST_BUZZER_UP_PRESSED:
		CALL 	_GOTO_TEST_LED
		LJMP	_TEST_BUZZER_UP_END
	_TEST_BUZZER_UP_NOT_RESSED:
		LJMP	_TEST_BUZZER_UP_END
	_TEST_BUZZER_UP_END:
	;----------------------------------;

	;-----------[ DOWN KEY ]-----------;
	MOV 	A, DOWN_KEY
	JNZ 	_TEST_BUZZER_DOWN_PRESSED
	LJMP 	_TEST_BUZZER_DOWN_NOT_RESSED

	_TEST_BUZZER_DOWN_PRESSED:
		CALL 	_GOTO_TEST_LED
		LJMP	_TEST_BUZZER_DOWN_END
	_TEST_BUZZER_DOWN_NOT_RESSED:
		LJMP	_TEST_BUZZER_DOWN_END
	_TEST_BUZZER_DOWN_END:
	;----------------------------------;

	;----------[ ENTER KEY ]-----------;
	MOV 	A, ENTER_KEY
	JNZ 	_TEST_BUZZER_ENTER_PRESSED
	LJMP 	_TEST_BUZZER_ENTER_NOT_RESSED

	_TEST_BUZZER_ENTER_PRESSED:
		CPL 	P1.5
		LJMP	_TEST_BUZZER_ENTER_END
	_TEST_BUZZER_ENTER_NOT_RESSED:
		LJMP	_TEST_BUZZER_ENTER_END
	_TEST_BUZZER_ENTER_END:
	;----------------------------------;

	;------------[ ESC KEY ]-----------;
	MOV 	A, ESC_KEY
	JNZ 	_TEST_BUZZER_ESC_PRESSED
	LJMP 	_TEST_BUZZER_ESC_NOT_RESSED

	_TEST_BUZZER_ESC_PRESSED:
		CALL 	_GOTO_TEST
		LJMP	_TEST_BUZZER_ESC_END
	_TEST_BUZZER_ESC_NOT_RESSED:
		LJMP	_TEST_BUZZER_ESC_END
	_TEST_BUZZER_ESC_END:
	;----------------------------------;

	LJMP	_LOOP_TIMER
;---------------------------------------------------------------------------
;                            T E S T  /  L E D
;---------------------------------------------------------------------------
_TEST_LED:
	;------------[ UP KEY ]------------;
	MOV 	A, UP_KEY
	JNZ 	_TEST_LED_UP_PRESSED
	LJMP 	_TEST_LED_UP_NOT_RESSED

	_TEST_LED_UP_PRESSED:
		CALL 	_GOTO_TEST_BUZZER
		LJMP	_TEST_LED_UP_END
	_TEST_LED_UP_NOT_RESSED:
		LJMP	_TEST_LED_UP_END
	_TEST_LED_UP_END:
	;----------------------------------;

	;-----------[ DOWN KEY ]-----------;
	MOV 	A, DOWN_KEY
	JNZ 	_TEST_LED_DOWN_PRESSED
	LJMP 	_TEST_LED_DOWN_NOT_RESSED

	_TEST_LED_DOWN_PRESSED:
		CALL 	_GOTO_TEST_BUZZER
		LJMP	_TEST_LED_DOWN_END
	_TEST_LED_DOWN_NOT_RESSED:
		LJMP	_TEST_LED_DOWN_END
	_TEST_LED_DOWN_END:
	;----------------------------------;

	;----------[ ENTER KEY ]-----------;
	MOV 	A, ENTER_KEY
	JNZ 	_TEST_LED_ENTER_PRESSED
	LJMP 	_TEST_LED_ENTER_NOT_RESSED

	_TEST_LED_ENTER_PRESSED:
		CPL 	P1.7
		LJMP	_TEST_LED_ENTER_END
	_TEST_LED_ENTER_NOT_RESSED:
		LJMP	_TEST_LED_ENTER_END
	_TEST_LED_ENTER_END:
	;----------------------------------;

	;------------[ ESC KEY ]-----------;
	MOV 	A, ESC_KEY
	JNZ 	_TEST_LED_ESC_PRESSED
	LJMP 	_TEST_LED_ESC_NOT_RESSED

	_TEST_LED_ESC_PRESSED:
		CALL 	_GOTO_TEST
		LJMP	_TEST_LED_ESC_END
	_TEST_LED_ESC_NOT_RESSED:
		LJMP	_TEST_LED_ESC_END
	_TEST_LED_ESC_END:
	;----------------------------------;

	LJMP	_LOOP_TIMER
;---------------------------------------------------------------------------
;                    O B S L U G A    K L A W I A T U R Y
;---------------------------------------------------------------------------
_KBD_HANDLE:
	MOV 	LEFT_KEY, 	#0d
	MOV 	RIGHT_KEY, 	#0d
	MOV 	UP_KEY,	 	#0d
	MOV 	DOWN_KEY, 	#0d
	MOV 	ENTER_KEY, 	#0d
	MOV 	ESC_KEY, 	#0d
;---------------------------------------------------------------------------
;               O B S L U G A    K L A W I S Z A    [ L E F T ]
;---------------------------------------------------------------------------
	MOV 	R5, #82d
	MOV 	R6, #82d
	_KBD_HANDLE_LEFT_10:
	_KBD_HANDLE_LEFT_40:
		MOV 	R0, #CSKB1
		MOVX 	A, @R0
		ANL 	A, #00000100b
		JNZ 	_KBD_HANDLE_LEFT_30
		DJNZ	R5, _KBD_HANDLE_LEFT_40
		DJNZ	R6, _KBD_HANDLE_LEFT_10
		MOV 	LEFT_KEY, #1d
	_KBD_HANDLE_LEFT_30:
;---------------------------------------------------------------------------
;               O B S L U G A    K L A W I S Z A    [ R I G H T ]
;---------------------------------------------------------------------------
	MOV 	R5, #82d
	MOV 	R6, #82d
	_KBD_HANDLE_RIGHT_10:
	_KBD_HANDLE_RIGHT_40:
		MOV 	R0, #CSKB1
		MOVX 	A, @R0
		ANL 	A, #00001000b
		JNZ 	_KBD_HANDLE_RIGHT_30
		DJNZ	R5, _KBD_HANDLE_RIGHT_40
		DJNZ	R6, _KBD_HANDLE_RIGHT_10
		MOV 	RIGHT_KEY, #1d
	_KBD_HANDLE_RIGHT_30:
;---------------------------------------------------------------------------
;               O B S L U G A    K L A W I S Z A    [ U P ]
;---------------------------------------------------------------------------
	MOV 	R5, #82d
	MOV 	R6, #82d
	_KBD_HANDLE_UP_10:
	_KBD_HANDLE_UP_40:
		MOV 	R0, #CSKB1
		MOVX 	A, @R0
		ANL 	A, #00010000b
		JNZ 	_KBD_HANDLE_UP_30
		DJNZ	R5, _KBD_HANDLE_UP_40
		DJNZ	R6, _KBD_HANDLE_UP_10
		MOV 	UP_KEY, #1d
	_KBD_HANDLE_UP_30:
;---------------------------------------------------------------------------
;               O B S L U G A    K L A W I S Z A    [ D O W N ]
;---------------------------------------------------------------------------
	MOV 	R5, #82d
	MOV 	R6, #82d
	_KBD_HANDLE_DOWN_10:
	_KBD_HANDLE_DOWN_40:
		MOV 	R0, #CSKB1
		MOVX 	A, @R0
		ANL 	A, #00100000b
		JNZ 	_KBD_HANDLE_DOWN_30
		DJNZ	R5, _KBD_HANDLE_DOWN_40
		DJNZ	R6, _KBD_HANDLE_DOWN_10
		MOV 	DOWN_KEY, #1d
	_KBD_HANDLE_DOWN_30:
;---------------------------------------------------------------------------
;               O B S L U G A    K L A W I S Z A    [ E S C ]
;---------------------------------------------------------------------------
	MOV 	R5, #82d
	MOV 	R6, #82d
	_KBD_HANDLE_ESC_10:
	_KBD_HANDLE_ESC_40:
		MOV 	R0, #CSKB1
		MOVX 	A, @R0
		ANL 	A, #01000000b
		JNZ 	_KBD_HANDLE_ESC_30
		DJNZ	R5, _KBD_HANDLE_ESC_40
		DJNZ	R6, _KBD_HANDLE_ESC_10
		MOV 	ESC_KEY, #1d
	_KBD_HANDLE_ESC_30:
;---------------------------------------------------------------------------
;               O B S L U G A    K L A W I S Z A    [ E N T E R ]
;---------------------------------------------------------------------------
	MOV 	R5, #82d
	MOV 	R6, #82d
	_KBD_HANDLE_ENTER_10:
	_KBD_HANDLE_ENTER_40:
		MOV 	R0, #CSKB1
		MOVX 	A, @R0
		ANL 	A, #10000000b
		JNZ 	_KBD_HANDLE_ENTER_30
		DJNZ	R5, _KBD_HANDLE_ENTER_40
		DJNZ	R6, _KBD_HANDLE_ENTER_10
		MOV 	ENTER_KEY, #1d
	_KBD_HANDLE_ENTER_30:
	RET
;---------------------------------------------------------------------------
;                       S K O K I    P O    M E N U
;---------------------------------------------------------------------------
_GOTO_MSG:
	CALL 	_LCD_CLEAR
	MOV 	STRING, #00h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STRING, #10h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STL, #00000001b
	MOV 	STH, #00000000b
	LJMP 	_LOOP

_GOTO_MSG_SEND:
	CALL 	_LCD_CLEAR
	MOV 	STRING, #10h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STRING, #40h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STL, #01000000b
	MOV 	STH, #00000000b
	LJMP 	_LOOP

_GOTO_SETTINGS:
	CALL 	_LCD_CLEAR
	MOV 	STRING, #00h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STRING, #20h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STL, #00000010b
	MOV 	STH, #00000000b
	LJMP 	_LOOP

_GOTO_TEST:
	CALL 	_LCD_CLEAR
	MOV 	STRING, #00h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STRING, #30h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STL, #00000100b
	MOV 	STH, #00000000b
	LJMP 	_LOOP

_GOTO_TEST_BUZZER:
	CALL 	_LCD_CLEAR
	MOV 	STRING, #30h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STRING, #80h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STL, #00001000b
	MOV 	STH, #00000000b
	LJMP 	_LOOP

_GOTO_TEST_LED:
	CALL 	_LCD_CLEAR
	MOV 	STRING, #30h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STRING, #90h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STL, #00010000b
	MOV 	STH, #00000000b
	LJMP 	_LOOP

_GOTO_SETTINGS_UPTIME:
	CALL 	_LCD_CLEAR
	MOV 	STRING, #20h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STRING, #60h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STL, #00100000b
	MOV 	STH, #00000000b
	LJMP 	_LOOP

_GOTO_SETTINGS_EDIT_MSG:
	CALL 	_LCD_CLEAR
	MOV 	STRING, #20h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STRING, #70h
	CALL 	_LCD_DISPLAY_STRING
	MOV 	STL, #10000000b
	MOV 	STH, #00000000b
	LJMP 	_LOOP

_GOTO_SETTINGS_EDIT_MSG_ENABLE:
	CALL 	_LCD_EDIT_MSG_DISPLAY
	MOV 	STL, #00000000b
	MOV 	STH, #00000001b
	LJMP 	_LOOP
;---------------------------------------------------------------------------
;                  W Y S W I E T L A N I E    U P T I M E
;---------------------------------------------------------------------------
_LCD_UPTIME_DISPLAY:
	CALL 	_LCD_CLEAR
	MOV 	R7, #91d					
	CALL 	_LCD_DATA_FROM_R7
	MOV  	A, HTIME
	MOV 	B, #10d
	DIV 	AB
	ADD 	A, #48d
	MOV 	R7, A
	CALL 	_LCD_DATA_FROM_R7
	MOV 	A, B
	ADD 	A, #48d
	MOV 	R7, A
	CALL 	_LCD_DATA_FROM_R7
	MOV 	R7, #58d
	CALL 	_LCD_DATA_FROM_R7
	MOV  	A, MTIME
	MOV 	B, #10d
	DIV 	AB
	ADD 	A, #48d
	MOV 	R7, A
	CALL 	_LCD_DATA_FROM_R7
	MOV 	A, B
	ADD 	A, #48d
	MOV 	R7, A
	CALL 	_LCD_DATA_FROM_R7
	MOV 	R7, #58d
	CALL 	_LCD_DATA_FROM_R7
	MOV  	A, STIME
	MOV 	B, #10d
	DIV 	AB
	ADD 	A, #48d
	MOV 	R7, A
	CALL 	_LCD_DATA_FROM_R7
	MOV 	A, B
	ADD 	A, #48d
	MOV 	R7, A
	CALL 	_LCD_DATA_FROM_R7
	MOV 	R7, #93d
	CALL 	_LCD_DATA_FROM_R7
	RET
;---------------------------------------------------------------------------
;                       D O S T E P N O S C    L C D
;---------------------------------------------------------------------------
_LCD_WAIT_WHILE_BUSY:
	_LCD_WAIT_LOOP:
		MOV 	DPTR, #LCDRC
      	MOVX 	A, @DPTR
	   	JNB 	ACC.7, _LCD_WAIT_END
	   	LJMP 	_LCD_WAIT_LOOP
	_LCD_WAIT_END:
		RET
;---------------------------------------------------------------------------
;                           R O Z K A Z    L C D
;---------------------------------------------------------------------------
_LCD_CMD_FROM_R7:
	CALL 	_LCD_WAIT_WHILE_BUSY
 	MOV 	A, R7
 	MOV 	DPTR, #LCDWC
  	MOVX 	@DPTR, A
	RET
;---------------------------------------------------------------------------
;                             D A N E    L C D
;---------------------------------------------------------------------------
_LCD_DATA_FROM_R7:
	CALL 	_LCD_WAIT_WHILE_BUSY
 	MOV 	A, R7
 	MOV 	DPTR, #LCDWD
 	MOVX 	@DPTR, A
	RET
;---------------------------------------------------------------------------
;			        I N I C J A L I Z A C J A    L C D
;---------------------------------------------------------------------------
_LCD_INIT:
	MOV 	R7, #00111000b				; function set
 	CALL 	_LCD_CMD_FROM_R7

 	MOV 	R7, #00001100b				; display on/off control
 	CALL 	_LCD_CMD_FROM_R7

 	MOV 	R7, #00000110b				; entry mode set
 	CALL 	_LCD_CMD_FROM_R7

 	CALL 	_LCD_CLEAR
	RET
;---------------------------------------------------------------------------
;			         C Z Y S Z C Z E N I E    L C D
;---------------------------------------------------------------------------
_LCD_CLEAR:
	MOV 	R7, #00000001b
 	CALL 	_LCD_CMD_FROM_R7
 	RET
;---------------------------------------------------------------------------
;			      W Y S W I E T L A N I E    N A P I S U
;---------------------------------------------------------------------------
_LCD_DISPLAY_STRING:
	MOV 	R5, #0
	MOV 	R6, #17
	_LCD_DISPLAY_WHILE:
		DJNZ 	R6, _LCD_DISPLAY_CONTINUE
		LJMP 	_LCD_DISPLAY_END
	_LCD_DISPLAY_CONTINUE:
    	MOV  	DPTR, #STRING_PATTERNS
    	MOV 	A, R5
    	ADD		A, STRING
		MOVC 	A, @A+DPTR
		MOV 	R7, A
		CALL 	_LCD_DATA_FROM_R7
		INC 	R5
		LJMP 	_LCD_DISPLAY_WHILE
	_LCD_DISPLAY_END:
		MOV 	R6, #24
		_LCD_DISPLAY_DO:
			MOV 	R7, #32
			CALL 	_LCD_DATA_FROM_R7
			DJNZ 	R6, _LCD_DISPLAY_DO
		RET
;---------------------------------------------------------------------------
;                      W Z O R C E    N A P I S O W
;---------------------------------------------------------------------------
STRING_PATTERNS:
	DB 	77,65,73,78,32,77,69,78,85,32,32,32,32,32,32,32 ; MAIN MENU		00h
	DB 	77,83,71,32,32,32,32,32,32,32,32,32,32,32,32,32 ; MSG 			10h
	DB 	83,69,84,84,73,78,71,83,32,32,32,32,32,32,32,32 ; SETTINGS 		20h
	DB 	84,69,83,84,32,32,32,32,32,32,32,32,32,32,32,32 ; TEST  		30h
	DB 	62,83,69,78,68,32,32,32,32,32,32,32,32,32,32,32 ; SEND 			40h
	DB 	62,82,69,65,68,32,32,32,32,32,32,32,32,32,32,32 ; READ 			50h
	DB 	62,85,80,84,73,77,69,32,32,32,32,32,32,32,32,32 ; UPTIME 		60h
	DB 	62,69,68,73,84,95,77,83,71,32,32,32,32,32,32,32 ; EDIT_MSG 		70h
	DB 	62,66,85,90,90,69,82,32,32,32,32,32,32,32,32,32 ; BUZZER 		80h
	DB 	62,76,69,68,32,32,32,32,32,32,32,32,32,32,32,32 ; LED 			90h
END