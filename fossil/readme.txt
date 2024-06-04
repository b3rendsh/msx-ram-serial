1655x Fossil Driver
===================

Fossil driver and tools for applications that use the fossil driver.
More detailed information is provided in the commmented source code.


FDRIVER.COM
-----------
Fossil driver version 2.0 for the 16550 and 16552 UART.
The UART type and I/O base port (0x20 or 0x80) is automatically detected.
The baudrate divider table is based on a 1.8432Mhz clock.

With MSXDOS 2.2 or higher you can create a FOSSIL.BAT in the root folder of 
the boot drive which will run after the fossil driver is loaded. 

There's an example FOSSIL.BAT in the BIN folder:
It starts the fossil driver and then the Erix terminal if there is a 
C:\ERIX folder with these programs.


FCHANNEL.COM
------------
With this tool you can set the channel on the 16552.
The channel can be provided as a commandline parameter.


FDINFO.COM
----------
Displays information about the currently loaded fossil driver.


Limitations
-----------
The driver 2.0 has only been tested with Erix terminal and file transfer on a 
MSX2 machine with MSXDOS1 and NEXTOR. On a MSX1 machine it is tested if the
driver loads and the fchannel and fdinfo programs work. 
If you find any malfunction please test first with DRV140.COM if it works ok 
with that driver and channel A (i.e. channel 0) before reporting the issue.



