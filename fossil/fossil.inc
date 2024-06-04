; FOSSIL.INC - Definitions


; MSX

VDP_STATUS	equ	$99		; TMS9918A status register (read)
ENASLT		equ	$0024		; ENASLT routine
NEWSTT		equ	$4601		; BASIC execute a text
DOSVER 		equ     $f313		; MSXDOS version
HIMSAV  	equ	$f349		; MSXDOS highmem
H_AUXINP	equ	$f371		; AUXINP hook
H_AUXOUT	equ	$f374		; AUXOUT hook
PUTPNT		equ	$f3f8		; Keyboard buffer write pointer
RTYCNT		equ	$fc9a		; Interrupt control
INTFLG		equ	$fc9b		; Interrupt flag (ctrl-stop)
JIFFY		equ	$fc9e		; Vsync counter used in TIME function
EXPTBL		equ	$fcc1		; Main BIOS slot address
H_STKE		equ	$feda		; STKERR hook
H_KEYI		equ	$fd9a		; KEYINT hook
H_TIMI		equ	$fd9f		; KEYINT/TIMI hook
H_CHPU		equ	$fda4		; CHPUT hook


; RS232C fossil driver

RS_MARKER	equ	$f3fc
RS_FLAG		equ	$5352		; "RS" (little endian)
RS_POINTER	equ	$f3fe
RS_VERSION	equ	$00
RS_INIT		equ	$03
RS_DEINIT	equ	$06
RS_SETBAUD	equ	$09
RS_PROTOCOL	equ	$0c
RS_CHANNEL	equ	$0f
RS_IN		equ	$12
RS_OUT		equ	$15
RS_INSTAT	equ	$18
RS_OUTSTAT	equ	$1b
RS_DTR		equ	$1e		; 
RS_RTS		equ	$21
RS_CARRIER	equ	$24
RS_CHARBUF	equ	$27
RS_SIZEBUF	equ	$2a
RS_FLUSHBUF	equ	$2d
RS_FASTINT	equ	$30
RS_H38STAT	equ	$33
RS_HCHPUT	equ	$36
RS_HKEYB	equ	$39
RS_GETINFO	equ	$3c


; UART 16550 / 16552

UARTBUF		equ	512		; Buffer 
UARTVER		equ	$0200		; BCD driver version number

UART_RBR	equ	0		; dlab=0: receiver buffer register (read)
UART_THR	equ	0		; dlab=0: transmitter holding register (write)
UART_IER	equ	1		; dlab=0: interrupt enable register 
UART_IIR	equ	2		; interrupt identifcation register (read)
UART_FCR	equ	2		; fifo control register (write)
UART_LCR	equ	3		; line control register 
UART_MCR	equ	4		; modem control register 
UART_LSR	equ	5		; line status register 
UART_MSR	equ	6		; modem status register 
UART_SCR	equ	7		; scratch register 
UART_DLL	equ	0		; dlab=1: divisor latch (ls)
UART_DLM	equ	1		; dlab=1: divisor latch (ms)
UART_AFR	equ	2		; dlab=1: alternate function register
