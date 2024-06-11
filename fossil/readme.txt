1655x Fossil Driver
===================

Fossil driver and tools for applications that use the fossil driver.
More detailed information is provided in the commmented source code.


FDRIVER.COM
-----------
Fossil driver version 2 for the 16550 and 16552 UART.
The UART type and I/O base port (0x20 or 0x80) is automatically detected.
The baudrate divider table is based on a 1.8432Mhz clock.

With MSXDOS 2.2 or higher you can create a FOSSIL.BAT in the root folder of 
the boot drive which will run after the fossil driver is loaded. 

There's an example FOSSIL.BAT in the BIN folder:
It starts the fossil driver and then the Erix terminal if there is a 
C:\ERIX folder with these programs.

Version 2.1 includes a dummy driver and preset configurations.
The interrupt driven receive buffer routines have been revised.
Version 2.2 saves separate speed and protocol settings for each channel,
Type "FDRIVER H" for help.


FDINFO.COM
----------
Displays information about the currently loaded fossil driver, status and 
configuration of the supported channels.


FMODE.COM
---------
With this tool you can set the speed and protocol for a channel, for use 
with applications that don't include channel configuration.
Type "FMODE H" for help.


FCHANNEL.COM
------------
With this tool you can select channel 0 or 1 on the 16552, for use with
applications that only support 1 channel. The channel number can be provided 
as a commandline parameter. 


XM.COM
------
Send and receive files with the xmodem file transfer protocol.
To support higher baudrates use RTS/CTS serial port setting at the other end.
To exchange files between 2 MSX computers use 9600 baud or lower.
Type "XM" with no parameters for help.


FTTY.COM
--------
Serial console: redirect screen and keyboard to current UART channel.
Works only when the screen is in a text mode, cursor control is limited.
The console option can be provided as a commandline parameter.


Limitations
-----------
The fossil driver v2 has been tested with the xmodem program, fossil tools
and Erix terminal and file transfer on a MSX2 machine with MSXDOS1 and NEXTOR.
On a MSX1 machine it is tested with the xmodem program and fossil tools. 
If you find any malfunction please test first with DRV140.COM if it works ok 
with that driver and channel A (i.e. channel 0) before reporting the issue.


Configuration information
=========================

Baudrates:
-----------
 0 =     75
 1 =    300
 2 =    600
 3 =   1200
 4 =   2400
 5 =   4800
 6 =   9600 
 7 =  19200
 8 =  38400
 9 =  57600
10 =  76800 (not supported)
11 = 115200
12 = 230400 (not supported)

Default baudrate is 19200 (7)

Protocol:
---------
Bit 7 6 5 4 3 2 1 0
    0 0 P P S S D D

P = Parity
	x0 none
	01 even
	11 odd

S = Stopbits
	00 (SYNC modes enable)
	01 1 stopbit
	10 1.5 stopbits
	11 2 stopbits

D = Databits
	00 5 bits or less
	01 6 bits
	10 7 bits
	11 8 bits

Default protocol is 00000111B (07H): No parity, 8 databits, 1 stopbit (8N1)

