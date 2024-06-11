; ------------------------------------------------------------------------------
; FTTY.ASM - Fossil serial console v1.0
; Copyright (C) 2024 H.J. Berends
;
; You can freely use, distribute or modify this program.
; It is provided freely and "as it is" in the hope that it will be useful, 
; but without any warranty of any kind, either expressed or implied.
; ------------------------------------------------------------------------------

		INCLUDE	"fossil.asm"
		
main:		call	f_deinit

		; get first character from commandline
                ld      a,($005d)	
		cp	'0'
                jp	z,con_off
                cp      '1'
                jp	z,con_echo_off
		cp	'2'
		jp	z,con_echo_on

		;Ask for coption
		ld	de,t_console
		call 	fd_print
		call	fd_input
		call	fd_crlf

		;Validate input
		cp	'0'
                jp	z,con_off
                cp      '1'
                jp	z,con_echo_off
		cp	'2'
		jp	z,con_echo_on
		jp	fd_exit
				

con_off:	ld	h,$00
		call	f_chput_hook
		call	f_keyb_hook
		jp	fd_exit


con_echo_off:	ld	hl,$0301
		jr	con_set

con_echo_on:	ld	hl,$0101

con_set:	call	f_chput_hook
		ld	h,l
		call	f_keyb_hook
		call	f_init
		jp	fd_exit
		
t_console:	db	"Fossil serial console:",$0d,$0a
		db	"----------------------",$0d,$0a
		db	"0 = Off",$0d,$0a
		db	"1 = On, local echo off",$0d,$0a
		db	"2 = On, local echo on",$0d,$0a,$0a
		db	"Enter choice (0-2) : $"


