; ------------------------------------------------------------------------------
; FOSSIL.ASM - Fossil tools initialization and helper routines v1.0
; Copyright (C) 2024 H.J. Berends
;
; You can freely use, distribute or modify this program.
; It is provided freely and "as it is" in the hope that it will be useful, 
; but without any warranty of any kind, either expressed or implied.
; ------------------------------------------------------------------------------

		include	"fossil.inc"

		ORG	$100
		jp	fd_init

; jump table fossil routines
f_getversion:	jp	0
f_init:		jp	0
f_deinit:	jp	0
f_setbaud:	jp	0
f_protocol:	jp	0
f_channel:	jp	0
f_rs_in:	jp	0
f_rs_out:	jp	0
f_rs_in_stat:	jp	0
f_rs_out_stat:	jp	0
f_dtr:		jp	0
f_rts:		jp	0
f_carrier:	jp	0
f_chars_in_buf:	jp	0
f_size_of_buf:	jp	0
f_flushbuf:	jp	0
f_fastint:	jp	0
f_hook38stat:	jp	0
f_chput_hook:	jp	0
f_keyb_hook:	jp	0
f_get_info:	jp	0


; ------------------------------------------------------------------------------
; Check if the fossil driver is loaded and initialize the jump table
; If the driver is not loaded the program will exit with an error message
; ------------------------------------------------------------------------------
fd_init:	ld	hl,(RS_MARKER)
		ld	de,RS_FLAG
		or	a
		sbc	hl,de
		jr	nz,_noDriver
                ld      hl,(RS_POINTER)		; get addres of jump table
                ld      de,f_getversion 	; point to my own table
                ld      bc,21*3			; number of entry's at this moment
                ldir				; make a copy of the table

		jp	main			; continue in the main module

_noDriver:	ld	de,_t_nodriver
		ld	c,9
		call	BDOS
		ld	c,0		
		jp	BDOS

_t_nodriver:	db	"Fossil driver not installed",$0d,$0a,"$"

; ------------------------------------------------------------------------------
; Use BDOS to print string terminated with $
; ------------------------------------------------------------------------------
fd_print:	push	de
		push	hl
		ld	c,9
		call	BDOS
		pop	hl
		pop	de
		ret

; ------------------------------------------------------------------------------
; Use BDOS to move cursor to next line
; ------------------------------------------------------------------------------
fd_crlf:	push	af
		push	de
		ld	de,_t_crlf
		call	fd_print
		pop	de
		pop	af
		ret

_t_crlf:	db	$0d,$0a,"$"

; ------------------------------------------------------------------------------
; Use BDOS to get character from keyboard
; ------------------------------------------------------------------------------
fd_input:	push	de
		push	hl
		ld	c,1
		call	BDOS
		pop	hl
		pop	de
		ret

; ------------------------------------------------------------------------------
; Use BDOS to exit / return to DOS
; ------------------------------------------------------------------------------
fd_exit:	ld	c,0		
		jp	BDOS

