# msx-ram-serial
 MSX 512KB RAM and 2 ports serial cart

## Introduction

This repository contains the design for a MSX cartridge that features a 512KB RAM mapper and 2 ports PV16552 serial interface.

Both features are not dependent on hardware level so you can choose to only populate the RAM components on the right side or serial components on the left side of the 
cartridge if you don't need the other feature.

Together with an IDE storage cart (BEER/MALT/SODA) it provides memory and serial ports to fully run RomWBW CP/M and work-alike operating systems on a MSX.

## Hardware

### 512KB RAM
The 512KB RAM is implemented as a Gouget style mapper. It requires only a few easy obtainable components. This mapper doesn't self initialize and has no back annotation.

I have tested the RAM with a BEER232 interface on a MSX1 computer: if you boot with MSXDOS 2 then MSXDOS 2 will initialize the memory. 

See also: https://www.msx.org/wiki/Memory_Mapper#Initialisation

### SERIAL

The serial interface is implemented with a PV16552 which is basically 2x 16550. After reset the registers are initialized the same as a 16550. 

The interface pins are TTL level and designed to be used with a [ftdi serial to usb adapter](hardware/images/ftdi.JPG).

Pin assignment left to right: GND,RTS,5V,RX,TX,CTS

Fit a jumper to JP1 or JP2 to provide +5V to the connected device (default not fitted) e.g. for usage with an ESP01 + adapter module.  

Jumpers JP3 and JP4 determine the I/O port range:  
Connect the upper 2 pins for 0x80 to 0x8F  
Connect the lower 2 pins for 0x20 to 0x2F  

Note: the PV16552 FIFO buffers are not usable in polled mode.

### Build instructions

The design of the cart was made so it is easy to build for anyone with basic soldering skills and knowledge of electronic circuits.

[Schematics](hardware/msx-ram-serial.pdf) and Kicad project files are provided so you can make changes if you want to. 

<a href="https://htmlpreview.github.io/?https://github.com/b3rendsh/msx-ram-serial/blob/main/hardware/bom/ibom.html">Interactive BOM</a>

 - Send the Gerbers ZIP file to your favorite PCB manufacturer for production
 - Source the components in the BOM
 - Populate the PCB with the components
 - Set the jumpers
 - Minimal test with a multi-meter the resistance between +5V and GND that there is no short circuit
 - The cart fits in a Konami type case with some cutouts

![alt text](hardware/images/msx%20ram-serial%20connectors%20and%20jumpers.jpg?raw=true "Connectors and Jumpers")

The default 1.8432Mhz clock works with most 3d party software, the hardware also supports other frequencies like a 18.432Mhz clock.

Connecting an ESP01 with Zimodem to one of the serial ports, for use with BBS or EMinEx applications, requires a small adapter board with 5V level shifters.

## Software

[Fossil driver and tools](fossil/)

A new 1655x fossil driver v2 and tools are created that utilize the dual channel 16552 capabilities. 
It will also work with a single channel 16550 and requires MSX1 / MSXDOS 1 or higher.

The new fossil tools like xmodem are designed to be backward compatible if possible, meaning they may also work with the fossil driver v1.40 for vintage MSX RS232 peripherals.

RomWBW CP/M for MSX is fully supported: in addition to the CRT you get 2 serial ports for use as a VT100 console or transfer files with xmodem.

The MSX JIO serial disk interface can be used with this cart instead of the software serial / joystick port.

Other MSX software and hardware add-ons that are designed to work with a 16550 UART most likely also work with the 16552 UART channel A. 

## Disclaimer
Build and use at your own risk! There is no warranty of any kind, either expressed or implied, that this cart will work with your MSX machine and/or software. 

## License

Copyright (C) 2026 H.J. Berends

This work is licensed under a <a href="http://creativecommons.org/licenses/by-nc-sa/4.0/" rel="nofollow">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
