# msx-ram-serial
 MSX 512KB RAM and 2 ports serial cart

## Introduction

This repository contains the design for a MSX cartridge that features 512KB RAM mapper and 2 ports PV16552 serial interface.

Both features are not dependent on hardware level so you can choose to only populate the RAM components on the right side or serial components on the left side of the 
cartridge if you don't need the other feature.   

## Hardware

### 512KB RAM
The 512KB RAM is implemented as a Gouget style mapper. It requires only a few easy obtainable components. This mapper doesn't self initialize and has no back annotation.

I have tested the RAM with a BEER232 interface on a MSX1 computer: if you boot with MSXDOS 2 then MSXDOS 2 will initialize the memory. 

See also: https://www.msx.org/wiki/Memory_Mapper#Initialisation

### SERIAL

The serial interface is implemented with a PV16552 which is basically 2x 16550. After reset the registers are initialized the same as a 16550. 

The interface pins are TTL level and designed to be used with a ftdi serial to usb adapter.
Pin assignment left to right: GND,RTS,5V,RX,TX,CTS
Fit a jumper to JP1 or JP2 to provide +5V to the connected device (default not fitted) e.g. for usage with an ESP01 + adapter module.  

Jumpers JP3 and JP4 determine the I/O port range:
Connect the upper 2 pins for 0x80 to 0x8F
Connect the lower 2 pins for 0x20 to 0x2F

### Build instructions

The design of the cart was made so it is easy to build for anyone with basic soldering skills and knowledge of electric circuits.  Schematics and Kicad project files are provided so you can make changes if you want to. 

 - Send the Gerbers ZIP file to your favorite PCB manufacturer
 - Source the components in the BOM
 - Populate the PCB with the components
 - Set the jumpers
 - Minimal test with a multi-meter that you have not created any short circuit

## Software

MSX software that is designed to work with a 16550 UART most likely also works with the 16552 UART channel A. I've tested the cart with the fossil driver and Erix terminal on a MSX2 machine and could exchange text and files with a PC using Tera Term.

### Work in progress / wishlist

 - [ ] Custom 16552 fossil driver to choose channel A or B and select I/O ports
 - [ ] RS232C BASIC Extension BIOS (loaded in RAM)
 - [ ] Xmodem file exchange program for MSX1
 - [ ] VT100 serial console for MSX1 and MSX2 (server not client)
 - [ ] 80 columns support with the serial console for MSX1
 - [ ] UNAPI TCP/IP with ESP01 Wifi (use/adapt one of the existing solutions)
 - [ ] Use serial console with CP/M Plus

## Disclaimer
Build and use at your own risk! There is no warranty of any kind, either expressed or implied, that this cart will work with your MSX machine and/or software. 

## License

Copyright (C) 2024 H.J. Berends

This work is licensed under a <a href="http://creativecommons.org/licenses/by-nc-sa/4.0/" rel="nofollow">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
