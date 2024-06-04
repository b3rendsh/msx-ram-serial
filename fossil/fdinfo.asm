; ------------------------------------------------------------------------------
; FDINFO.ASM - Print fossil driver info v1.0
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

		ld	hl,RS_GETINFO
		call	rs_routine

		ld	de,fdInfo
		call	print

		ld	de,fdVersion+17
		call	writeBCD
		ld	a,(hl)
		ld	(version2),a
		ld	de,fdVersion+15
		call	writeBCD
		ld	de,fdVersion
		call	print

		ld	de,fdReceive
		call	printHex

		ld	de,fdSend
		call	printHex

		ld	de,fdProtocol
		call	printHex

		ld	de,fdChput
		call	printHex
 
		ld	de,fdKeyboard
		call	printHex

		ld	de,fdRTS
		call	printHex
 
		ld	de,fdDTR
		call	printHex
 
		ld	de,fdChannel
		call	printHex
 
		ld	de,fdHardware
		call	printHex

		ld	a,(version2)
		cp	2
		jp	c,exit

		ld	de,fdPort
		call	printHex

		ld	de,fdType
		call	printHex
 
		jp	exit

noDriver:	ld	de,notInstalled
		call	print

exit:		ld	c,0
		jp	5

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
print:		push	hl
		ld	c,9
		call	5
		pop	hl
		ret
		
rs_routine:	ld	de,(RS_POINTER)	
		add	hl,de
		push	hl
		ld	h,b		
		ld	l,c
		ret	

notInstalled:	db	"Fossil driver not installed",$0d,$0a,"$"
fdInfo:		db	"Fossil driver info:",$0d,$0a
		db	"-------------------",$0d,$0a,"$"
fdVersion:	db	"Version      :     ",$0d,$0a,"$"
fdReceive:	db	"Receive speed:     ",$0d,$0a,"$"
fdSend:		db	"Send speed   :     ",$0d,$0a,"$"
fdProtocol:	db	"Protocol     :     ",$0d,$0a,"$"
fdChput:	db	"Chput status :     ",$0d,$0a,"$"
fdKeyboard:	db	"Keyb status  :     ",$0d,$0a,"$"
fdRTS:		db	"RTS status   :     ",$0d,$0a,"$"
fdDTR:		db	"DTR status   :     ",$0d,$0a,"$"
fdChannel:	db	"Channel      :     ",$0d,$0a,"$"
fdHardware: 	db	"Hardware info:     ",$0d,$0a,"$"
version2:	db	0
fdPort: 	db	"I/O base port:     ",$0d,$0a,"$"
fdType: 	db	"UART type    :     ",$0d,$0a,"$"


