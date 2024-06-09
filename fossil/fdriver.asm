; ------------------------------------------------------------------------------
; FDRIVER.ASM - Fossil Driver 1655X v2.1
; Copyright (C) 2024 H.J. Berends
;
; Parts of the code and comments are derived from sources created by Erik Maas:
; see driver140 folder for the 16550 driver 1.40
;
; You can freely use, distribute or modify this program.
; It is provided freely and "as it is" in the hope that it will be useful, 
; but without any warranty of any kind, either expressed or implied.
; ------------------------------------------------------------------------------
; This module is an enhanced fossil driver for the 16550 or 16552 UART.
; It is based on the fossil driver specification by Erik Maas.
; Changes:
; --------
; V2.1:
; + Fixed errors in RTS flag and receive buffer logic
; + Added dummy driver
; + Added driver select parameter:
;	0 = dummy
;	1 = 16550 port $20
;	2 = 16550 port $80
;	3 = 16552 port $20
;	4 = 16552 port $80
;	anything else: autodetect
; + Init/deinit routines: keep current protocol setting
;
; V1.0 (driver v2.0)
; + UART 16550 or 16552 detection at I/O ports 0x80 or 0x20
; + Added channel selection routine
; + No BASIC screen
; + Loader optimized
; + MSXDOS 1: returns to dos
; + MSXDOS 2: returns to dos and executes "FOSSIL.BAT" if it exists
; x Removed commandline options
; x Removed drivers for other uarts
; ------------------------------------------------------------------------------

		INCLUDE "fossil.inc"

		ORG	$100

		jp	loader

; ------------------------------------------------------------------------------
; 1655x - Header
; ------------------------------------------------------------------------------
hdr_info:	db	"Fossil driver v"		; Driver version
		db	'0'+(UARTVER/256)
		db	"."
		db	'0'+(UARTVER/16) % 16
		db	'0'+(UARTVER % 16)
		db	$0d,$0a
hdr_type:	db	"1655X UART+FIFO, port "	; Interface
hdr_port:	db	"0"
		db	"x",$0d,$0a,"$"

; ------------------------------------------------------------------------------
; 1655x - Driver relocation table
; ------------------------------------------------------------------------------

rel_tab:	dw	p00,p01,p02,p03,p04,p05,p06,p07			; jump table
		dw	p08,p09,p10,p11,p12,p13,p14,p15
		dw	p16,p17,p18,p19,p20

		;	p00						; getversion
		dw	p0101,p0102,p0103,p0104,p0105,p0106,p0107,p0108	; init
		dw	p0201,p0202,p0203				; deinit
		dw	p0301,p0302,p0303,p0304,p0305,p0306,p0307	; setbaud
		dw	p0401,p0402					; protocol
		dw	p0501,p0502,p0503,p0504				; channel
		dw	p0601,p0602,p0603,p0604,p0605,p0606,p0607,p0608	; rs_in
		dw	p0701,p0702					; rs_out
		dw	p0801						; rs_in_stat
		dw	p0901						; rs_out_stat
		dw	p1001,p1002					; dtr
		dw	p1101,p1102,p1103,p1104				; rts
		;	p12						; carrier
		dw	p1301						; chars_in_buf
		; 	p14						; size_of_buf
		dw	p1501,p1502,p1503,p1504				; flushbuf
		dw	p1601,p1602,p1603,p1604,p1605,p1606,p1607	; fastint
		dw	p1608,p1609,p1610				
		dw	p1701						; hookstat38
		dw	p1801,p1802					; chput_hook
		dw	p1901						; keyb_hook
		dw	p2001						; getinfo
					; 
		dw	p2101,p2102,p2103,p2104,p2105,p2106,p2107	; fh_keyi
		dw	p2108,p2109,p2110
									; fh_aux_out
		dw	p2301						; fh_aux_in
		dw	p2401,p2402,p2403				; fh_chput
		dw	p2501,p2502,p2503,p2504,p2505,p2506,p2507	; fh_timi
		dw	p2508,p2509					
		; 	p26						; fo_timi	

		dw	$ffff						; end of table

; ------------------------------------------------------------------------------
; 1655x - Driver code
; ------------------------------------------------------------------------------
tsr_start:
		PHASE	$0		; driver will be relocated by the loader
		
p_rs_driver:
p00:		jp	getversion	; Version H.L (H.L packed BCD)
p01:		jp	init		; Initialize (activate) fossil driver
p02:		jp	deinit		; Deactivate fossil driver
p03:		jp	setbaud 	; H=Tx baud rate, L=Rx baud rate
					; 0 = 75	1 = 300
					; 2 = 600	3 = 1200
					; 4 = 2400	5 = 4800
					; 6 = 9600	7 = 19200
					; 8 = 38400 	9 = 57600
					; A = 76800 	B = 115200
					; C = 230400	

		; In register H and L, the driver reports the actually selected rate.
		; This is done in case the hardware does not support the selected
		; rate. If the driver does not support the selected rate, it selects
		; the highest possible rate below the selected.
		; The 1655x driver sets the receive baudrate to the same value as transmit baudrate.
		; The divisor table is based on a 1.8432 clock which limits max baudrate to 115200.


p04:		jp	protocol	; H 0-1 data bits
					;	00 5 bits or less
					;	01 6 bits
					;	10 7 bits
					;	11 8 bits
					;   2-3 stop bits
					;	00 (SYNC modes enable)
					;	01 1 stopbit
					;	10 1.5 stopbits
					;	11 2 stopbits
					;   4-5 parity
					;	x0 none
					;	01 even
					;	11 odd
					;   6-7 0
					; L = 0
					; This register is for future extensions
					; and it should be set to 0

p05:		jp	channel 	; H = channel number: 0 or 1 (for use with dual channel uart)

p06:		jp	rs_in		; [A] = Received byte
p07:		jp	rs_out		; [A] = Transmit byte

p08:		jp	rs_in_stat	; A=0 No data in buffer     A!=0 Data in buffer
p09:		jp	rs_out_stat	; A=0 Not ready for sending A!=0 Data can be send 
					; (in the v1.40 source this was commented the wrong way around)

p10:		jp	dtr		; H=0 drop DTR, H=255 raise DTR
p11:		jp	rts		; H=0 drop RTS, H=255 raise RTS
p12:		jp	carrier		; A=0 no carrier  A!= carrier detect

p13:		jp	chars_in_buf	; Return : HL = characters in Rx buf.
p14:		jp	size_of_buf	; Return : HL = size of buffer
p15:		jp	flushbuf	; Flush the receive buffer

p16:		jp	fastint 	; use &H0038 hook for speedup
					; H=0 Connect driver fast
					; H=1 Release fast hook

		; The driver uses hook H.KEYI, but this is not very fast. Since this hook
		; is called after some BIOS work, and after this hook, the BIOS continues
		; to do some time waisting things.
		; Therefore, this driver has the option to install itselve at the &H38 hook.
		; This can be done if there is RAM available at &H0000-&H3FFF. This is the
		; case in DOS(2).

p17:		jp	hook38stat	; set status for 0038 hook
					; H=0 Enable all interrupts
					; H=1 Only RS232C and VDP interrupt

		; This function is for use with fastint.
		; When the "connect driver fast" has been issued, you can control how the
		; interrupt handler of the driver behaves.
		; If every interrupt is supported, there is slightly more processor time
		; used after an interrupt from the RS232C interface.


p18:		jp	chput_hook	; redirect CHPUT data to RS232
					; H=0 no redirection
					; H=1 redirect with echo
					; H=3 redirect without echo (faster)

		; All print commands that would be issued using the BIOS calls, will be
		; transmitted through the RS232C interface.

p19:		jp	keyb_hook	; redirect RS232 to keyboard buffer
					; H=0 release hook, H!=0 bend hook

		; With this function, you can redirect all incoming RS232C data to the keyboard buffer.
		; This and the previous function are nice to let a terminal control your MSX computer.

p20:		jp	get_info	; Return HL = Pointer to driver info block


; ------------------------------------------------------------------------------
; Driver info block
					;Offset	Bytes	Description

driver_info:	dw	UARTVER		; +0	2	Version number +1 contains main version
					; 		+0 contains sub-version both packed BCD

speed_status:	db	7		; +2	1	Current receive speed index (default 19200)

		db	7		; +3	1	Current send speed index (default 19200)

cur_proto:	db	00000111b	; +4	1	Current protocol (Data/Stop/Parity: default 8N1)

hook_txt:	db	0		; +5	1	ChPut_Hook redirection status

hook_get:	db	0		; +6	1	Keyboard_Hook redirection status

cur_rts:	db	3		; +7	1	Current RTS status (default 3)

cur_dtr:	db	0		; +8	1	Current DTR status (default 0)

cur_channl:	db	0		; +9	1	Current channel (default 0)

		db	8		; +10	1	8 = 16650 UART with FIFO (not changed)

; Extra fields driver v2+

uport:		db	$80		; +11	1	UART base I/O port (detect at runtime)

utype:		db	$1		; +12	1	UART type: 1=16550 2=16552 (detect at runtime)


; ------------------------------------------------------------------------------
; Driver routines


; p00 ------------------------------------------
getversion:	ld	hl,UARTVER
		ret

; p01 ------------------------------------------
init:		di
p0101:		ld	a,(cur_proto)		; use current protocol setting
		ld	h,a
		ld	l,0
p0102:		call	protocol
		ld	h,$ff
p0103:		call	dtr
		ld	h,$ff
p0104:		call	rts
p0105:		call	set_speed		; set the uart at the right speed
p0106:		ld	a,(ubase+UART_FCR)
		ld	c,a
		ld	a,$07
		out	(c),a			; enable FIFO
p0107:		ld	a,(ubase+UART_IER)
		ld	c,a
		ld	a,$01
		out	(c),a			; enable uart interrupts
p0108:		call	flushbuf		; flush/init the receive buffer
		ei				; ei after flushbuf
		ret

; p02 ------------------------------------------
deinit:		di
		ld	h,0
p0201:		call	dtr
		ld	h,0
p0202:		call	rts
p0203:		ld	a,(ubase+UART_IER)
		ld	c,a
		xor	a			; a=0
		out	(c),a			; disable uart interrupts
		ei
		ret

; p03 ------------------------------------------
setbaud:	ld	a,h
		cp	$0c+$01			; max baud setting is $0c
		jr	c,setbaud1
		ld	h,$0b
setbaud1:	ld	l,h			; set receive/transmit to same baudrate
p0301:		ld	(speed_status),hl
setbaud2:	ld	h,0
		add	hl,hl
p0302:		ld	de,speedtable
		add	hl,de
p0303:		ld	a,(ubase+UART_LCR)
		ld	c,a
		di
		in	a,(c)
		or	$80
		out	(c),a			; set DLAB=1
p0304:		ld	a,(ubase+UART_DLL)
		ld	c,a
		ld	a,(hl)
		out	(c),a			; set divisor latch (LS)
		inc	hl
p0305:		ld	a,(ubase+UART_DLM)
		ld	c,a
		ld	a,(hl)
		out	(c),a			; set divisor latch (MS)
p0306:		ld	a,(ubase+UART_LCR)
		ld	c,a
		in	a,(c)
		and	$7f
		out	(c),a			; set DLAB=0
		ei
		ret

set_speed:
p0307:		ld	hl,(speed_status)
		jr	setbaud2

; Speedtable for 1,8432 MHz
speedtable:	dw	1536		;0 75
		dw	384		;1 300
		dw	192		;2 600
		dw	96		;3 1200
		dw	48		;4 2400
		dw	24		;5 4800
		dw	12		;6 9600 
		dw	6		;7 19200
		dw	3		;8 38400
		dw	2		;9 57600
		dw	2		;A 76800 (not supported)
		dw	1		;B 115200
		dw	1		;C 230400 (not supported)

; p04 ------------------------------------------
protocol:	ld	a,h
p0401:		ld	(cur_proto),a
		and	000000111b		; filter out bits/character
		xor	000000100b		; and stopbits
		ld	b,a			; put it in our work register
		ld	a,h
		and	000110000b		; parity
		xor	000100000b
		srl	a
		or	b
		ld	b,a
p0402:		ld	a,(ubase+UART_LCR)
		ld	c,a
		out	(c),b
		ret

; p05 ------------------------------------------
channel:	di
p0501:		ld	a,(utype)		; check if the uart type supports dual channel
		ld	b,a
		ld	a,h
		cp	b
		jr	nc,end_channel		; nc=channel number too high
p0502:		ld	(cur_channl),a
		or	a			; channel 0?
p0503:		ld	a,(uport)
		jr	z,set_channel		; z=channel 0
		add	a,8			; port offset for channel 1
set_channel:	ld	b,8			; 8 registers
p0504:		ld	hl,ubase		; address of register 0
set_reg:	ld	(hl),a
		inc	a
		inc	hl
		djnz	set_reg
end_channel:	ei
		ret

; p06 ------------------------------------------
rs_in:		di
p0601:		ld	hl,(inbufnumber)
		ld	a,h
		or	l			; any data received?
		jr	z,eiret 		; z=no
		dec	hl
p0602:		ld	(inbufnumber),hl	
		ld	de,UARTBUF/2
		or	a			; clear carry
		sbc	hl,de			; bytes in buffer lower than threshold?
		jr	nc,rs_in_1		; nc=no 
p0603:		ld	a,(cur_rts)
		or	010b			; rts on
p0604:		call	rts_inside

rs_in_1:	
p0605:		ld	de,(inbufget)
		ld	a,(de)
		inc	de
p0606:		ld	hl,inbufend		; compare (inbufget+1) to inbufend
		ld	c,a
		ld	a,l
		xor	e			; e = l ?
		jr	nz,retchr		; nz=no
		ld	a,h
		xor	d			; d = h ?
		jr	nz,retchr		; nz=no
p0607:		ld	de,inbuf
		or	$ff			; reset Z flag
retchr:
p0608:		ld	(inbufget),de
		ld	a,c
eiret:		ei
		ret

; p07 ------------------------------------------
rs_out:		ei
		ld	b,a
rs_out1:
p0701:		ld	a,(ubase+UART_LSR)
		ld	c,a
		in	a,(c)
		and	$20
		jr	z,rs_out1
p0702:		ld	a,(ubase+UART_THR)
		ld	c,a
		out	(c),b
		ret

; p08 ------------------------------------------
rs_in_stat:
p0801:		ld	hl,(inbufnumber)
		ld	a,h
		or	l
		ret	z
		or	$ff
		ret

; p09 ------------------------------------------
rs_out_stat:
p0901:		ld	a,(ubase+UART_LSR)
		ld	c,a
		in	a,(c)
		and	$20
		ret	z
		or	$ff
		ret

; p10 ------------------------------------------
dtr:		ld	a,h
p1001:		ld	(cur_dtr),a
		and	000000001b
		ld	b,a
p1002:		ld	a,(ubase+UART_MCR)
		ld	c,a
		di
		in	a,(c)
		and	011111110b
		or	b
		out	(c),a
		ei
		ret

; p11 ------------------------------------------
rts:		ld	a,h
		and	1
		ld	h,a
		di
p1101:		ld	a,(cur_rts)
		and	2
		or	h
p1102:		call	rts_inside
		ei
		ret

rts_inside:
p1103:		ld	(cur_rts),a
		ld	h,0
		cp	3
		jr	nz,rts_1
		ld	h,2
rts_1:
p1104:		ld	a,(ubase+UART_MCR)
		ld	c,a
		in	a,(c)
		and	011111101b
		or	h
		out	(c),a
		ret

; p12 ------------------------------------------
carrier:	ld	a,$ff
		ret

; p13 ------------------------------------------
chars_in_buf:
p1301:		ld	hl,(inbufnumber)
		ret

; p14 ------------------------------------------
size_of_buf:	ld	hl,UARTBUF
		ret

; p15 ------------------------------------------
flushbuf:	di
p1501:		ld	hl,inbuf
p1502:		ld	(inbufget),hl
p1503:		ld	(inbufput),hl
		ld	hl,0
p1504:		ld	(inbufnumber),hl
		ei
		ret

; p16 ------------------------------------------
fastint:	ld	a,h
		or	a
		jr	nz,fastint2
p1601:		call	checkhook
		ret	z
		ld	hl,$0038
p1602:		ld	de,old_0038
		ld	bc,3
		ldir
		ld	a,$c3	
p1603:		ld	hl,hook0038
		di
		ld	($0038+0),a
		ld	($0038+1),hl
		ei
		ret
fastint2:
p1604:		call	checkhook
		ret	nz
		di
p1605:		ld	hl,old_0038
		ld	de,$0038
		ld	bc,3
		ldir
		ei
		ret

checkhook:	ld	hl,($0038+$01)
p1606:		ld	de,hook0038
		or	a
		sbc	hl,de
		ret

hook0038:	push	af
		push	bc
p1607:		ld	a,(ubase+UART_LSR)
		ld	c,a
		in	a,(c)
		pop	bc
		and	1
		jr	z,quit0038
		push	hl
		push	de
		push	bc
hook0038_1:
p1608:		call	int_rs_in
p1609:		ld	a,(ubase+UART_LSR)
		ld	c,a
		in	a,(c)
		and	1
		jr	nz,hook0038_1
		pop	bc
		pop	de
		pop	hl
stop_0038:	pop	af
		ei
		reti

quit0038:
p1610:		ld	a,(do_0038)
		or	a
		jr	nz,sub_0038
		pop	af
old_0038:	ds	3,$c9
sub_0038:	in	a,(VDP_STATUS)		; read VDP status register
		and	$80
		jr	z,stop_0038		; nz=vsync interrupt
		push	bc
		ld	bc,(JIFFY)
		inc	bc
		ld	(JIFFY),bc		; Increase vsync counter
		pop	bc
		jr	stop_0038

; p17 ------------------------------------------
hook38stat:	ld	a,h
p1701:		ld	(do_0038),a
		ret

; p18 ------------------------------------------
chput_hook:	ld	a,h
		and	3
p1801:		ld	(hook_txt),a
		and	2
p1802:		ld	(hook_txtecho),a
		ret

; p19 ------------------------------------------
keyb_hook:	ld	a,h
p1901:		ld	(hook_get),a
		ret

; p20 ------------------------------------------
get_info:
p2001:		ld	hl,driver_info
		ret

; ----------------------------------------------
; interrupt routines

fh_keyi:	push	af
		push	bc
p2101:		ld	a,(ubase+UART_LSR)
		ld	c,a
		in	a,(c)
		bit	7,a			; error or break condition?
		jr	nz,no_rs_int		; nz=yes
		and	1
		jr	z,no_rs_int
		push	hl
		push	de
rs_in1:		
p2102:		call	int_rs_in
p2103:		ld	a,(ubase+UART_LSR)
		ld	c,a
		in	a,(c)
		and	1
		jr	nz,rs_in1
		pop	de
		pop	hl
no_rs_int:	pop	bc
		pop	af
		ret

int_rs_in:	db	$11			; ld de,(inbufput)
inbufput:	dw	0			; initialized to inbuf in flushbuf
		db	$21			; ld hl,(inbufnumber)
inbufnumber:	dw	0
p2104:		ld	a,(ubase+UART_RBR)
		ld	c,a
		in	a,(c)
		ld	(de),a
		inc	de
		inc	hl
p2105:		ld	(inbufnumber),hl
		push	de
		ld	de,UARTBUF*2/3
		or	a			; clear carry
		sbc	hl,de			; bytes in buffer higher than threshold?
		jr	c,int_rs_in2		; c=no
p2106:		ld	a,(cur_rts)		
		and	001b			; rts off
p2107:		call	rts_inside
int_rs_in2:	pop	de
p2108:		ld	hl,inbufend
		ld	a,l
		xor	e
		jr	nz,int_rs_in1
		ld	a,h
		xor	d
		jr	nz,int_rs_in1
p2109:		ld	de,inbuf
int_rs_in1:
p2110:		ld	(inbufput),de
		ret

fh_aux_out:	EQU	rs_out			

fh_aux_in:
p2301:		call	rs_in
		jr	z,fh_aux_in
		ret

fh_chput:	ld	b,a
p2401:		ld	a,(hook_txt)
		or	a
		ret	z
		ld	a,b
p2402:		call	rs_out
p2403:		ld	a,(hook_txtecho)
		or	a
		ret	z
		pop	hl			; ditch return address
		pop	af
		pop	bc
		pop	de
		pop	hl
		ret				; return without echo


fh_timi:	push	af
p2501:		ld	a,(hook_get)
		or	a			; execute hook?
p2502:		jp	z,hook_rs_ret		; z=no

		push	hl		
		push	de	
		push	bc

p2503:		ld	hl,(inbufnumber)
		ld	a,h
		or	l			; is there data in the buffer?
p2504:		jp	z,end_get_rs		; z=no

		dec	hl
p2505:		ld	(inbufnumber),hl
p2506:		ld	de,(inbufget)
		ld	a,(de)			; get character
		inc	de			; buffer pointer +1
p2507:		ld	hl,inbufend
		or	a			; at end of buffer?
		sbc	hl,de			; 
		jr	nz,timi_1		; nz=no
p2508:		ld	de,inbuf
timi_1:
p2509:		ld	(inbufget),de		; save buffer pointer
	
		ld	hl,(PUTPNT)		; get keyboard write pointer
		ld	(hl),a			; put character
		inc	hl			; pointer +1
		ld	(PUTPNT),hl		; save pointer
		ld	de,BUFEND
		or	a			; at end of buffer?
		sbc	hl,de			; 
		jr	nz,end_get_rs		; nz=no
		ld	hl,KEYBUF		; init pointer to start
		ld	(PUTPNT),hl		; 
end_get_rs:	pop	bc
		pop	de
		pop	hl
hook_rs_ret:	pop	af
fo_timi:	ds	5,$c9


; ----------------------------------------------
; Variables

baud:		dw	0
hook_txtecho:	db	0
do_0038:	db	0	
inbuf:		ds	UARTBUF,0		; receive buffer
inbufend:	db	0
inbufget:	dw	0			; pointer for buffers (initialized to inbuf in flushbuf)
ubase:		db	0,1,2,3,4,5,6,7		; UART register ports set at runtime

		DEPHASE			

tsr_length:	dw	$-tsr_start		; size of the driver code

		dw	tsr_start
		dw	rel_tab
		dw	fh_keyi
		dw	fh_aux_out
		dw	fh_aux_in
		dw	fh_chput
		dw	fh_timi
		dw	fo_timi



; ------------------------------------------------------------------------------
; Dummy - Header
; ------------------------------------------------------------------------------
d_hdr_info:	db	"Fossil driver v"
		db	'0'+(UARTVER/256)
		db	"."
		db	'0'+(UARTVER/16) % 16
		db	'0'+(UARTVER % 16)
		db	$0d,$0a
		db	"Dummy UART, 2 channels"	
		db	$0d,$0a,"$"

; ------------------------------------------------------------------------------
; Dummy - Driver relocation table
; ------------------------------------------------------------------------------

d_rel_tab:	dw	d00,d01,d02,d03,d04,d05,d06,d07
		dw	d08,d09,d10,d11,d12,d13,d14,d15
		dw	d16,d17,d18,d19,d20
		dw	d0101,d0102
		dw	d0201,d0202
		dw	d0301
		dw	d0401
		dw	d0501,d0502
		dw	d2001
		dw	$ffff

; ------------------------------------------------------------------------------
; Dummy - Driver code
; ------------------------------------------------------------------------------
d_tsr_start:
		PHASE	$0

d_rs_driver:
d00:		jp	d_getversion	
d01:		jp	d_init		
d02:		jp	d_deinit		
d03:		jp	d_setbaud 	
d04:		jp	d_protocol	
d05:		jp	d_channel 
d06:		jp	d_rs_in
d07:		jp	d_rs_out
d08:		jp	d_rs_in_stat
d09:		jp	d_rs_out_stat
d10:		jp	d_dtr
d11:		jp	d_rts
d12:		jp	d_carrier
d13:		jp	d_chars_in_buf
d14:		jp	d_size_of_buf
d15:		jp	d_flushbuf
d16:		jp	d_fastint
d17:		jp	d_hook38stat
d18:		jp	d_chput_hook	
d19:		jp	d_keyb_hook	
d20:		jp	d_get_info	

; ------------------------------------------------------------------------------
; Driver info block

d_driver_info:	dw	UARTVER		
d_speed_status:	db	7
		db	7
d_cur_proto:	db	00000111b
d_hook_txt:	db	0
d_hook_get:	db	0
d_cur_rts:	db	0
d_cur_dtr:	db	0
d_cur_channl:	db	0
		db	0
d_uport:	db	$80
d_utype:	db	$2

; ------------------------------------------------------------------------------
; Driver routines

d_getversion:	ld	hl,UARTVER
		ret

d_init:		xor	a
d0101:		ld	(d_cur_dtr),a
d0102:		ld	(d_cur_rts),a
		ret

d_deinit:	ld	a,$ff
d0201:		ld	(d_cur_dtr),a
d0202:		ld	(d_cur_rts),a
		ret

d_setbaud:	ld	a,h
		cp	$0c+$01			; max baud setting is $0c
		jr	c,d_setbaud1
		ld	h,$0b
d_setbaud1:	ld	l,h			; set receive/transmit to same baudrate
d0301:		ld	(d_speed_status),hl
		ret

d_protocol:	ld	a,h
d0401:		ld	(d_cur_proto),a
		ret

d_channel:	
d0501:		ld	a,(d_utype)		; check if the uart type supports dual channel
		ld	b,a
		ld	a,h
		cp	b
		ret	nc			; nc=channel number too high
d0502:		ld	(d_cur_channl),a
		ret

d_rs_in:	xor	a			; never data received
		ret

d_rs_out:	ret				; nop

d_rs_in_stat:	xor	a			; no data in buffer
		ret

d_rs_out_stat:	ld	a,$ff			; always ready to send
		ret

d_dtr:		ret

d_rts:		ret

d_carrier:	ld	a,$ff
		ret

d_chars_in_buf:	ld	hl,0
		ret

d_size_of_buf:	ld	hl,UARTBUF
		ret

d_flushbuf:	ret

d_fastint:	ret

d_hook38stat:	ret

d_chput_hook:	ret

d_keyb_hook:	ret

d_get_info:
d2001:		ld	hl,d_driver_info
		ret

; interrupt routines

d_fh_keyi:	ret
d_fh_aux_out:	ret
d_fh_aux_in:	ret
d_fh_chput:	ret
d_fh_timi:	ret
d_fo_timi:	ds	5,$c9

		DEPHASE			

d_tsr_length:	dw	$-d_tsr_start		; size of the driver code

		dw	d_tsr_start
		dw	d_rel_tab
		dw	d_fh_keyi
		dw	d_fh_aux_out
		dw	d_fh_aux_in
		dw	d_fh_chput
		dw	d_fh_timi
		dw	d_fo_timi

; ------------------------------------------------------------------------------
; Main loader routine:
; Check driver status, detect the uart and install the driver
; ------------------------------------------------------------------------------
loader:		
		; check if a driver is already loaded
		ld	hl,(RS_MARKER)
		ld	de,RS_FLAG
		or	a
		sbc	hl,de
		ld	de,t_loaded
		jp	z,endLoader

		; check memory availability in page 3
		ld	hl,(HIMSAV)		; MSXDOS highmem
		ld	a,h
		cp	$c8			; lower than $c800?
		ld	de,t_mem_error
		jp	c,endLoader		; c=yes


		; check for driver parameter 
                ld      a,($005d)		; first character of commandline parameters:
		cp	' '
		jp	z,autodetect

		cp	'0'			; 0 = dummy driver
		jp	nz,check_1
		ld	de,d_hdr_info		
		ld	c,9			; print driver info
		call	5
		ld	hl,d_tsr_length		; dummy driver variables
		jp	copy_driver

check_1:	cp      '1'			; 1 = 16550 I/O base $20
                jp	nz, check_2
		ld	a,1
		ld	(uart_type),a
		ld	a,$20
		ld	(uart_port),a
		jp	set_uart

check_2:	cp      '2'			; 2 = 16550 I/O base $80
	        jp	nz, check_3
		ld	a,1
		ld	(uart_type),a
		ld	a,$80
		ld	(uart_port),a
		jp	set_uart

check_3:	cp	'3'			; 3 = 16552 I/O base $20
		jp	nz,check_4
		ld	a,2
		ld	(uart_type),a
		ld	a,$20
		ld	(uart_port),a
		jp	set_uart

check_4:	cp	'4'			; 4 = 16552 I/O base $80
		jp	nz,help
		ld	a,2
		ld	(uart_type),a
		ld	a,$80
		ld	(uart_port),a
		jp	set_uart

help:		; display help
		ld	de,t_help
		jp	endLoader

autodetect:	; detect uart ports and type
		call	detect1655x		
		ld	a,(uart_type)
		or	a
		jp	z,notDetected

set_uart:	; set uart port and type in header and infoblock
		ld	hl,tsr_start
		ld	de,uport
		add	hl,de
		ld	a,(uart_port)
		ld	(hl),a
		and	$f0			; Convert high nibble to ascii number
		rrca
		rrca
		rrca
		rrca
		add	a,'0'
		ld	(hdr_port),a		; Update header with port number
		; set uart type
		inc	hl			; utype
		ld	a,(uart_type)
		ld	(hl),a
		cp	1
		jr	nz,set_hdr_type
		dec	a
set_hdr_type:	add	a,'0'
		ld	(hdr_type+4),a		; Update header with uart type
		ld	de,hdr_info
		ld	c,9			; print driver info
		call	5
		ld	hl,tsr_length		; 1655x driver variables

copy_driver:	; copy driver variables 
		; hl contains source location
		ld	de,DRV_VAR
		ld	bc,18
		ldir
		
		; copy installer to $8100
		ld	hl,installer
		ld	de,$8100
		ld	bc,inst_length
		ldir

		; clear commandline
                ld        hl,$0000                      
                ld        ($0080),hl

		; copy environment item SHELL to PROGRAM (DOS 2)
		ld	hl,e_shell
		ld	de,e_buffer
		ld	bc,$ff6b		; get environment item
		call	5
		ld	hl,e_program
		ld	c,$6c			; set environment item
		call	5

		; jump to installer in page 2
		jp	$8100

notDetected:	ld	de,t_error
endLoader:	ld	c,9			; print message
		call	5
		ld	c,0			; exit to DOS
		jp	5


t_error:	db	"No UART detected",$0d,$0a,"$"
t_loaded:	db	"Driver is installed",$0d,$0a,"$"
t_mem_error:	db	"Not enough memory for driver",$0d,$0a,"$"
t_help:		db	"Usage: FDRIVER [option]",$0d,$0a,$0a
		db	"With no option specified, the UART",$0d,$a
		db	"will be autodetected and installed.",$0d,$0a,$0a
		db	"Option: 0=dummy",$0d,$0a
		db	"        1=16550 0x20  2=16550 0x80",$0d,$0a
		db	"        3=16552 0x20  4=16552 0x80",$0d,$0a,"$"

e_shell:	db	"SHELL",0
e_program:	db	"PROGRAM",0
e_buffer:	ds	256,0


; ------------------------------------------------------------------------------
; Subroutine: detect 16550 or 16552 uart at ports 0x80 or 0x20
; This is a very basic detection routine, sub variants are not detected.
; Sets variables:
; uart_port = 0x20 or 0x80
; uart_type = 0=no uart, 1=16550 and 2=16552
; Todo: use detected uart ports and channel in driver code
; ------------------------------------------------------------------------------
detect1655x:	ld	a,$80
		ld	(uart_port),a		; default ports 0x80
		ld	hl,uart_type
		ld	(hl),0			; set channels to 0 (no uart)
		call	detectUart
		inc	a
		jr	z,detect20
		inc	(hl)			; set channels to 1
		ld	a,$88
		call	detectUart
		inc	a
		ret	z
		inc	(hl)			; set channels to 2
		ret

detect20:	ld	a,$20
		ld	(uart_port),a
		inc	a
		call	detectUart
		ret	z
		inc	(hl)			; set channels to 1
		ld	a,$28
		call	detectUart
		inc	a
		ret	z
		inc	(hl)
		ret

; Detect uart returns $ff if not found
detectUart:	inc	a			; register 1
		ld	c,a
		in	a,(c)
		cp	$ff
		ret	z
scratchTest:	ld	a,c			; I/O base
		add	a,6			; register 7
		ld	c,a
		ld	a,$aa
		out	(c),a
		nop
		nop
		in	b,(c)
		cp	b
		jr	nz,uartNotFound
		ld	a,$55
		out	(c),a
		nop
		nop
		in	b,(c)
		cp	b
		ret	z
uartNotFound:	ld	a,$ff
		ret

uart_port:	db	0
uart_type:	db	0

; ------------------------------------------------------------------------------
; Subroutine: installler in $8100
; at label load_dos the main BIOS is loaded in page 0 and BASIC in page 1
; ------------------------------------------------------------------------------
installer:
		PHASE	$8100

install:	ld	sp,$c200

		ld	hl,(HIMSAV)		; MSXDOS highmem
		ld	de,(DRV_LENGTH)
		or	a
		sbc	hl,de			; calculate driver address
		ld	(HIMSAV),hl		; set new highmem

		; copy driver to destination
		ex	de,hl			; set de to tsr address
		ld	hl,(DRV_START)		; start address of unrelocated driver code
		ld	bc,(DRV_LENGTH)
		ldir

		; Adapt relocated driver code
		ld	de,(HIMSAV)		; start address of program
		ld	hl,(DRV_RELTAB)		; relocation table
adapt:		ld	c,(hl)
		inc	hl
		ld	b,(hl)			; bc = patch address
		inc	hl
		inc	bc			; adjust offset -1
		ld	a,b
		or	c
		jp	z,sethook		; z=end of relocation table
		push	hl
		ld	h,d
		ld	l,e
		add	hl,bc			; hl = relocated base + patch address
		dec	hl
		ld	a,(hl)
		cp	$ed			; 2 byte instruction?
		jr	nz,adapt1
		inc	hl
adapt1:		inc	hl
		ld	c,(hl)			
		inc	hl
		ld	b,(hl)			; bc = value
		push	de
		ex	de,hl
		add	hl,bc			
		ex	de,hl			; de = relocated base + value
		ld	(hl),d			; write relocated value to relocated patch address
		dec	hl
		ld	(hl),e
		pop	de
		pop	hl
		jp	adapt

sethook:	di
		ld	de,(HIMSAV)
		ld	a,$c3

		ld	hl,(DRV_KEYI)		; redirect H.KEYI to fossil driver
		add	hl,de
		ld	(H_KEYI),a		; receiver routines
		ld	(H_KEYI+1),hl		; (old H.KEYI will be deleted!)

		ld	hl,(DRV_CHPUT)		; redirect CHPUT to fossil driver
		add	hl,de
		ld	(H_CHPU),a
		ld	(H_CHPU+1),hl

		ld	hl,(DRV_AUXIN)		; redirect AUXIN 
		add	hl,de
		ld	(H_AUXINP),a
		ld	(H_AUXINP+1),hl

		ld	hl,(DRV_AUXOUT)		; redirect AUXOUT
		add	hl,de
		ld	(H_AUXOUT),a
		ld	(H_AUXOUT+1),hl

		push	de
		ld	hl,(DRV_OTIMI)
		add	hl,de
		ex	de,hl
		ld	hl,H_TIMI		; save old hook H_TIMI
		ld	bc,5
		ldir
		pop	de

		ld	hl,(DRV_HTIMI)
		add	hl,de
		ld	(H_TIMI),a		; KEYBOARD buffer routine
		ld	(H_TIMI+1),hl

		ld	hl,RS_FLAG
		ld	(RS_MARKER),hl
		ld	(RS_POINTER),de		; set pointer to jump tabel

		; set channel to 0 and deinit
		ld	hl,RS_CHANNEL
		add	hl,de
		ld	(channel_ad+1),hl
		ld	h,0			; channel 0
channel_ad:	call	0			; call channel
		ld	hl,RS_DEINIT
		add	hl,de
		ld	(deinit_ad+1),hl
deinit_ad:	call	0			; call deinit
		ei

		; check dos version and call system
		ld      a,(DOSVER)
		cp      $22			; DOS version 2.2 or higher?
		jp	nc,load_dos2

		; In DOS1 the MSXDOS ENASLT routine cannot be used
		; Load BIOS: enable page 0 in slot 0
load_dos1:	di
		in	a,($a8)
		and	$fc
		out	($a8),a
		ld	a,($ffff)
		cpl
		and	$fc
		ld	($ffff),a
		ei
		; Load BASIC in page 1
		ld	a,(EXPTBL)
		ld	h,$40
		call	ENASLT			; Use ENASLOT from BIOS
		ld	hl,call_system1
		push	hl
		jp	cmd_system
		
	
		; DOS2: jump to basic and do _system
		; code snippet derived from ramhelpr.asm by Konamiman
load_dos2:     	ld	a,(EXPTBL)		; Main BIOS slot
	        push    af
        	ld      h,0			; page 0
	        call    ENASLT
	        pop     af
	        ld      h,$40			; page 1
	        call    ENASLT
		ld	hl,call_system2
		push	hl

cmd_system:	xor	a
		ld	hl,$f41f
		ld	($f860),hl
		ld	hl,$f423		
		ld	($f41f),hl
		ld	(hl),a
		ld	hl,$f52c
		ld	($f421),hl
		ld	(hl),a
		ld	hl,$f42c
		ld	($f862),hl

		pop	hl
		jp	NEWSTT

call_system1:	db	":_SYSTEM",$00
call_system2:	db	":_SYSTEM(\"FOSSIL.BAT\")",$00

		DEPHASE

inst_length:	EQU	$-installer

; Dynamic driver variables
DRV_VAR		equ	$9000
DRV_LENGTH	equ	$9000
DRV_START	equ	$9002
DRV_RELTAB	equ	$9004
DRV_KEYI	equ	$9006
DRV_AUXOUT	equ	$9008
DRV_AUXIN	equ	$900A
DRV_CHPUT	equ	$900C
DRV_HTIMI	equ	$900E
DRV_OTIMI	equ	$9010

