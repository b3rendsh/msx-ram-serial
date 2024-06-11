; ------------------------------------------------------------------------------
; FMODE.ASM - Set speed and protocol for a channel v1.1
; Copyright (C) 2024 H.J. Berends
;
; You can freely use, distribute or modify this program.
; It is provided freely and "as it is" in the hope that it will be useful, 
; but without any warranty of any kind, either expressed or implied.
; ------------------------------------------------------------------------------


		INCLUDE	"fossil.asm"

main:		call	f_get_info
		push	hl
		pop	iy			; point iy to start of fossil infoblock

		;parse parameters
		ld	ix,$81			; point ix to start of parameter area
		call	skip_blank		; skip blank and load char in A
		jp	z,print_help

		;set channel
		call	get_number
		jp	c,print_error
		cp	2
		jp	nc,print_error
		ld	(var_channel),a
		
		ld	a,(ix)
		cp	':'
		jp	nz,print_error
		
		; get speed value
		inc	ix
		ld	a,(ix)
		cp	0
		jp	z,fd_exit
		cp	','
		jp	z,set_protocol
		call	get_number
		jp	c,print_error
		cp	13
		jp	nc,print_error

		; set speed value in fossil info block
		ld	(var_speed),a
		ld	a,(iy+FI_CURCHANNEL)
		ld	b,a
		ld	a,(var_channel)
		cp	b			; is current channel?
		jp	nz,upd_speed_info	; nz=no

		ld	a,(var_speed)
		ld	h,a
		ld	l,a
		call	f_setbaud
		jr	speed2

upd_speed_info:	or	a
		ld	a,(var_speed)
		jr	nz,speed1
		ld	(iy+FI_CURSPEED0),a	
		ld	(iy+FI_CURSPEED0+1),a	; set send and receive to same value
		jr	speed2
speed1:		ld	(iy+FI_CURSPEED1),a
		ld	(iy+FI_CURSPEED1+1),a

speed2:		ld	a,(ix)
		cp	','
		jp	nz,fd_exit

set_protocol:	inc	ix
		call	get_number
		jp	c,print_error	
		cp	0
		jp	z,fd_exit
		cp	64
		jp	nc,print_error

		; set protocol value in fossil info block
		ld	(var_protocol),a
		ld	a,(iy+FI_CURCHANNEL)
		ld	b,a
		ld	a,(var_channel)
		cp	b			; is current channel?
		jp	nz,upd_proto_info	; nz=no

		ld	a,(var_protocol)
		ld	h,a
		call	f_protocol
		jp	fd_exit

upd_proto_info:	or	a
		ld	a,(var_protocol)
		jr	nz,proto1
		ld	(iy+FI_CURPROTO0),a
		jp	fd_exit
proto1:		ld	(iy+FI_CURPROTO1),a
		jp	fd_exit


print_help:	ld	de,t_help
		jr	print_exit
print_error:	ld	de,t_error
print_exit:	call	fd_print
		jp	fd_exit

t_help:		db	"Usage:",$0d,$0a
		db	"FMODE <channel>:<speed>,<protocol>",$0d,$0a,$0a
		db	"channel  = 0..1",$0d,$0a
		db	"speed    = 0..12",$0d,$0a
		db	"protocol = 0..63",$0d,$0a,$0a
		db	"Examples:",$0d,$0a
		db	"0:8,7  set channel 0 to 38400 / 8N1",$0d,$0a
		db	"1:9,46 set channel 1 to 57600 / 7E2",$0d,$0a
		db	"0:7    set channel 0 to 19200 baud",$0d,$0a,$0a
		db	"0:,46  set channel 0 to 7E2 protocol",$0d,$0a,$0a

		db	"Use FDINFO to display current config.$"
t_error:	db	"Invalid option, type FMODE for help.",$0d,$0a,"$"


var_channel:	db	0
var_speed:	db	0
var_protocol:	db	0

; ------------------------------------------------------------------------------
; Parse parameter subroutines
; ------------------------------------------------------------------------------
get_number:	ld	c,0		
getnum_loop:	ld	a,(ix)
		cp	'0'
		jr	c,getnum_end
		cp	'9'+1
		jr	nc,getnum_end

		; c = c x 10
		ld	a,c
		rlca		; x2
		ret	c
		rlca		; x4
		ret	c
		add	a,c	; x5
		ret	c	
		rlca		; x10
		ret	c
		ld	c,a

		ld	a,(ix)
		sub	'0'
		add	a,c
		ret	c
		ld	c,a
		inc	ix
		jr	getnum_loop

getnum_end:	ld	a,c
		or	a			; reset C flag
		ret


skip_blank:	ld	a,(ix)
		or	a
		ret	z
		cp	' '
		ret	nz
		inc	ix
		jr	skip_blank
;
