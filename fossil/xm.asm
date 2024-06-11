; ------------------------------------------------------------------------------
; XM.ASM - XMODEM with MSX fossil driver v1.1
; Copyright (C) 2024 H.J. Berends
;
; You can freely use, distribute or modify this program.
; It is provided freely and "as it is" in the hope that it will be useful, 
; but without any warranty of any kind, either expressed or implied.
; ------------------------------------------------------------------------------
; Uses the generic xmodem 12.5 implementation for CP/M, and 
; uses the MSX fossil driver for serial interface hardware.
; ------------------------------------------------------------------------------

		; routines used by xmodem program
		PUBLIC	CONOUT
		PUBLIC	MINIT
		PUBLIC	UNINIT
		PUBLIC	SENDR
		PUBLIC	CAROK
		PUBLIC	MDIN
		PUBLIC	GETCHR
		PUBLIC	RCVRDY
		PUBLIC	SNDRDY
		PUBLIC	SPEED
		PUBLIC	EXTRA1
		PUBLIC	EXTRA2
		PUBLIC	EXTRA3

		; main routine of xmodem program
		EXTERN	BEGIN

		include "fossil.asm"	; initialize fossil and jump to main

; ------------------------------------------------------------------------------
; Translate xmodem <--> fossil routines
; ------------------------------------------------------------------------------

main:		equ	BEGIN		; jump to xmodem program begin

; customized routines for xmodem
CONOUT:		equ	console_output	; Output to local console
MINIT:		equ	init		; Initialization routine 
UNINIT:		equ	deinit		; Undo whatever MINIT did (or return)
SENDR:		equ	send_char	; Send character (via POP PSW)
CAROK:		equ	carrier		; Test for carrier
MDIN:		equ	receive_char	; Receive data byte
GETCHR:		equ	get_char	; Get character from modem
RCVRDY:		equ	receive_ready	; Check receive ready (A - ERRCDE)
SNDRDY:		equ	send_ready	; Check send ready
SPEED:		equ	get_speed	; Get speed value for transfer time

; extra routines not used
EXTRA1:		
EXTRA2:
EXTRA3:		ret


; ------------------------------------------------------------------------------
; Direct console i/o
; Parameter: E=character (and a copy in C)
; Registers are saved in the xmodem CTYPE and CTYPEL routine
; ------------------------------------------------------------------------------
console_output:	ld	c,2
		jp	BDOS

; ------------------------------------------------------------------------------
; Initialization routine
; Parameters: A=port (channel) $ff=use current channel
; ------------------------------------------------------------------------------
init:		push	af
		call	f_get_info
		push	hl	
		pop	iy
		ld	a,(iy+FI_CURCHANNEL)
		ld	(sav_channel),a
		pop	af
		ld	h,a
		inc	a
		jr	z,init1
		call	f_channel		; set channel

init1:		ld	a,(iy+FI_DRIVERINFO+1)
		ld	de, t_version
		call	writeBCD
		ld	a,(iy+FI_DRIVERINFO)
		ld	de,t_version+3
		call	writeBCD
		ld	a,(iy+FI_CURCHANNEL)
		add	a,'0'
		ld	(t_channel),a
		ld	de,t_init		; print fossil version and channel 
		call	fd_print
		jp	f_init			; init fossil driver

writeBCD:	ld	b,a
		and	$f0
		rrca
		rrca
		rrca	
		rrca
		add	a,'0'
		ld	(de),a		
		ld	a,b
		and	$0f
		add	a,'0'
		inc	de
		ld	(de),a
		ret

t_init:		db	"MSX fossil driver v"
t_version:	db	"00.00 channel "
t_channel:	db	"0",$0d,$0a,"$"
sav_channel:	db	0

; ------------------------------------------------------------------------------
; De-initialization routine
; ------------------------------------------------------------------------------
deinit:		call	f_deinit
		ld	a,(sav_channel)
		ld	h,a
		jp	f_channel

; ------------------------------------------------------------------------------
; Carrier routine 
; translate fossil carrier flag to xmodem carrier flag
; ------------------------------------------------------------------------------
carrier:	call	f_carrier
		or	a
		jr	z,no_carrier
		xor	a
		ret
no_carrier:	dec	a
		ret

; ------------------------------------------------------------------------------
; Get speed routine
; In the xmodem module it is only used to calculate transfer time 
; ------------------------------------------------------------------------------
get_speed:	push	de
		push	hl
		call	f_get_info
		inc	hl
		inc	hl		; offset +2 for current speed
		ld	a,(hl)		; get current speed
		ld	hl,speed_table
		ld	d,0
		ld	e,a
		add	hl,de
		ld	a,(hl)		; convert fossil speed to xmodem value
		pop	hl
		pop	de
		ret

; ------------------------------------------------------------------------------
; Send ready 
; xmodem_ready = NOT fossil_ready
; ------------------------------------------------------------------------------
send_ready:	push	bc
		call	f_rs_out_stat
		pop	bc
		or	a
		jr	z,s_zero
		xor	a		; set Z flag
		ret
s_zero:		dec	a		; reset Z flag
		ret

; ------------------------------------------------------------------------------
; Send character routine 
; Parameter: character is on the stack!
; ------------------------------------------------------------------------------
send_char:	pop	af
		push	bc
		call	f_rs_out
		pop	bc
		ret		
		
; ------------------------------------------------------------------------------
; Receive ready routine 
; xmodem_ready = NOT fossil_ready
; returns: flag: Z=ready NZ=not ready, A = error code
; ------------------------------------------------------------------------------
receive_ready:	push	hl
		call	f_rs_in_stat
		pop	hl
		or	a
		jr	z,r_zero
		xor	a		; set Z flag
		ret
r_zero:		inc	a		; clear Z flag
		ld	a,0		; no change to Z flag, set error code to 0
		ret

; ------------------------------------------------------------------------------
; Get / Receive character routine 
; ------------------------------------------------------------------------------
get_char:	call	receive_ready
		ret	nz

receive_char:	push	bc
		push	de
		push	hl
		call	f_rs_in
		pop	hl
		pop	de
		pop	bc
		ret		


; ------------------------------------------------------------------------------
; Convert fossil to xmodem speeds
speed_table:	db	0		; 0:      75 --> 0:    110
		db	1		; 1:     300 --> 1:    300
		db	3		; 2:     600 --> 3:    600
		db	5		; 3:    1200 --> 5:   1200
		db	6		; 4:    2400 --> 6:   2400
		db	7		; 5:    4800 --> 7:   4800
		db	8		; 6:    9600 --> 8:   9600
		db	9		; 7:   19200 --> 9:  19200
		db	10		; 8:   38400 --> 10: 38400
		db	11		; 9:   57600 --> 11: 57600
		db	11		; 10:  76800 --> 11: 57600
		db	12		; 11: 115200 --> 12:115200
		db	12		; 12: 230400 --> 12:115200

		
