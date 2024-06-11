# Make z80 binary from asm source with z88dk tools
# Todo: make generic rules

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

.PHONY:	all fdinfo fchannel fdriver fmode ftty xm clean

all:	fdinfo fchannel fdriver fmode ftty xm

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

fmode:	
	@echo Assembling..
	z80asm -b -Oobj -o=fmode.com fmode.asm
	$(CP) obj$/fmode.com $(BIN)$/FMODE.COM
	@echo done

ftty:	
	@echo Assembling..
	z80asm -b -Oobj -o=ftty.com ftty.asm
	$(CP) obj$/ftty.com $(BIN)$/FTTY.COM
	@echo done

xm:	
	@echo Assembling..
	z80asm -b -l -m -Oobj -o=xm.com xm.asm xmdm125.asm
	$(CP) obj$/xm.com $(BIN)$/XM.COM
	@echo done

clean:
	$(RMF) obj$/*
	@echo Cleanup done
