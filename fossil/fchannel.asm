; ------------------------------------------------------------------------------
; FCHANNEL.ASM - Set fossil channel v1.1 
; Copyright (C) 2024 H.J. Berends
;
; You can freely use, distribute or modify this program.
; It is provided freely and "as it is" in the hope that it will be useful, 
; but without any warranty of any kind, either expressed or implied.
; ------------------------------------------------------------------------------

		INCLUDE	"fossil.asm"
		
main:		; get first character from commandline
                ld      a,($005d)	
		cp	'0'
                jp	z,setChannel
                cp      '1'
                jp	z, setChannel

		;Ask for channel
		ld	de,t_channel
		call 	fd_print
		call	fd_input
		call	fd_crlf

		;Validate input
		cp	'0'
                jp	z,setChannel
                cp      '1'
                jp	z, setChannel
		jp	fd_exit
				
setChannel:	sub	'0'
		push	af
		call	f_deinit		; deactivate driver
		pop	hl
		call	f_channel		; set channel
		call	f_get_info
		push	hl
		pop	iy
		ld	a,(iy+FI_CURCHANNEL)	; get current channel
		add	'0'
		ld	(newChannel),a
		ld	de,t_switched	;
		call	fd_print
		jp	fd_exit
		
t_channel:	db	"Enter channel number (0-1) : $"
t_switched:	db	"Channel is set to "
newChannel:	db	"X",$0d,$0a,"$"

