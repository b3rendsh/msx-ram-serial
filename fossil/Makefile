# Make z80 binary from asm source with z88dk tools

# system agnostic commands
ifdef ComSpec
	RMF	:= del /f /q
	SEARCH	:= find
	CP	:= copy /b
	/	:= $(strip \)
else
	RMF	:= rm -f 
	SEARCH	:= grep
	CP	:= cp
	/	:= /
endif 

# Note: folder for binaries must be existing folder
BIN 	:= .$/bin

.PHONY:	all fdinfo fchannel fdriver clean

all:	fdinfo fchannel fdriver

fdinfo:	
	@echo Assembling..
	z80asm -b -Oobj -o=fdinfo.com fdinfo.asm
	$(CP) obj$/fdinfo.com $(BIN)$/FDINFO.COM
	@echo done

fchannel:	
	@echo Assembling..
	z80asm -b -Oobj -o=fchannel.com fchannel.asm
	$(CP) obj$/fchannel.com $(BIN)$/FCHANNEL.COM
	@echo done

fdriver:	
	@echo Assembling..
	z80asm -b -l -m -Oobj -o=fdriver.com fdriver.asm
	$(CP) obj$/fdriver.com $(BIN)$/FDRIVER.COM
	@echo done

clean:
	$(RMF) obj$/*
	@echo Cleanup done
