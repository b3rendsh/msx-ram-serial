; ------------------------------------------------------------------------------
; FDINFO.ASM - Print fossil driver info v1.1
; Copyright (C) 2024 H.J. Berends
;
; You can freely use, distribute or modify this program.
; It is provided freely and "as it is" in the hope that it will be useful, 
; but without any warranty of any kind, either expressed or implied.
; ------------------------------------------------------------------------------

		INCLUDE	"fossil.asm"

main:		call	f_get_info

		ld	de,fdInfo
		call	fd_print

		ld	de,fdVersion+17
		call	writeBCD
		ld	a,(hl)
		ld	(version2),a
		ld	de,fdVersion+15
		call	writeBCD
		ld	de,fdVersion
		call	fd_print

		ld	de,fdStatus
		ld	b,9
print_status:	push	bc
		call	printHex
		pop	bc
		djnz	print_status

		ld	a,(version2)
		cp	2
		jp	c,fd_exit

		ld	de,fdExtra
		ld	b,8
print_extra:	push	bc
		call	printHex
		pop	bc
		djnz	print_extra
 
		jp	fd_exit

writeBCD:	ld	a,(hl)
		inc	hl
		ld	b,a
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

printHex:	ld	ix,15
		add	ix,de
		ld	a,(hl)
		inc	hl
		ld	b,a
		and	$f0
		rrca
		rrca
		rrca	
		rrca
		add	a,'0'
		cp	'9'+1
		jr	c,digit1
		add	a,7
digit1:		ld	(ix+0),a		
		ld	a,b
		and	$0f
		add	a,'0'
		cp	'9'+1
		jr	c,digit2
		add	a,7
digit2:		ld	(ix+1),a
		call	fd_print
		push	hl
		ld	hl,22
		add	hl,de
		ld	d,h
		ld	e,l
		pop	hl
		ret

fdInfo:		db	"Fossil driver info:",$0d,$0a
		db	"-------------------",$0d,$0a,"$"
fdVersion:	db	"Version      :     ",$0d,$0a,"$"
fdStatus:	db	"Receive speed:     ",$0d,$0a,"$"
		db	"Send speed   :     ",$0d,$0a,"$"
		db	"Protocol     :     ",$0d,$0a,"$"
		db	"Chput status :     ",$0d,$0a,"$"
		db	"Keyb status  :     ",$0d,$0a,"$"
		db	"RTS status   :     ",$0d,$0a,"$"
		db	"DTR status   :     ",$0d,$0a,"$"
		db	"Channel      :     ",$0d,$0a,"$"
 		db	"Hardware info:     ",$0d,$0a,"$"
fdExtra: 	db	"I/O base port:     ",$0d,$0a,"$"
		db	"UART type    :     ",$0d,$0a,"$"
	 	db	"Receive  ch 0:     ",$0d,$0a,"$"
	 	db	"Send     ch 0:     ",$0d,$0a,"$"
	 	db	"Protocol ch 0:     ",$0d,$0a,"$"
	 	db	"Receive  ch 1:     ",$0d,$0a,"$"
	 	db	"Send     ch 1:     ",$0d,$0a,"$"
	 	db	"Protocol ch 1:     ",$0d,$0a,"$"
version2:	db	0


