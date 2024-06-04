; ------------------------------------------------------------------------------
; FCHANNEL.ASM - Set fossil channel v1.0 
; Copyright (C) 2024 H.J. Berends
;
; You can freely use, distribute or modify this program.
; It is provided freely and "as it is" in the hope that it will be useful, 
; but without any warranty of any kind, either expressed or implied.
; ------------------------------------------------------------------------------

		INCLUDE	"fossil.inc"
		
		ORG	$100


main:		ld	hl,(RS_MARKER)
		ld	de,RS_FLAG
		or	a
		sbc	hl,de
		jp	nz,noDriver

		; deinit
		ld	hl,RS_DEINIT
		call	rs_routine		

		; get channel from commandline
                ld      a,($005d)
		cp	'0'
                jp	z,setChannel
                cp      '1'
                jp	z, setChannel

		;Ask for channel
		ld	de,t_channel
		call 	print

		ld	c,1
		call	5
		push	af
		ld	de,t_crlf
		call	print
		pop	af
		cp	'0'
                jp	z,setChannel
                cp      '1'
                jp	z, setChannel

		jp	exit
				
		; set channel
setChannel:	ld	(newChannel),a
		sub	'0'
		ld	b,a
		ld	hl,RS_CHANNEL
		call	rs_routine			

		; print result
		ld	de,t_switched
		call	print
		
exit:		ld	c,0		
		jp	5

noDriver:	ld	de,t_nodriver
		call	print
		jr	exit

print:		ld	c,9
		call	5
		ret

rs_routine:	ld	de,(RS_POINTER)	
		add	hl,de
		push	hl
		ld	h,b		
		ld	l,c
		ret	

t_nodriver:	db	"Fossil driver not installed",$0d,$0a,"$"
t_channel:	db	"Enter channel number (0-1) : $"
t_crlf:		db	$0d,$0a,"$"
t_switched:	db	"Channel switched to "
newChannel:	db	"X",$0d,$0a,"$"

