:: © GorosVia 15.jun.15 - https://github.com/gorosvia/avrusb - GVEngine v3.3.0
:: Engine CMD params: %1 - filename in ""; %2 - mode; %3 - additional command in "";

@echo off
set cfgname="%~dp0GVengine.conf"
set prog="usbtiny"
set prognm=bin\avrdude_v6.1.exe
set tasmnm=bin\tavrasm_v1.22.exe
set avrasmnm=bin\avrasm_v2.1.57.exe
set hexbinnm=bin\hex2bin_v2.0.exe
set binhexnm=bin\bin2hex.exe
set avrdvkeyw=
set avrdvkeyr=-v
set avrdakey=
set tasmvkey=-v
set tasmpkey=-x
set aasmvkey=-v2
set aasmpkey=-w
set usetavrasm=true
set encopy=true
set part=%~x1
if exist %cfgname% (
	for /f "usebackq eol=# delims== tokens=1,2" %%i in (%cfgname%) do (set %%i=%%j)
	)else (
	echo CMD engine : Warning - config file not found!
)
if not "%encopy%" == "false" (
	echo CMD engine version 3.3.0 RC 15.jun.2015
)
:: Pass %3 param to avrdude. Used by fuse programmer.
if "%2" == "duderule" (
	"%~dp0%prognm%" -p "%part:~1%" -c %prog% %avrdvkeyw% %avrdakey% %~3
)else (
:: Call avrdude without specific arguments to check connection with target MCU
if "%2" == "check" (
	"%~dp0%prognm%" -p "%part:~1%" -c %prog% %avrdvkeyr% %avrdakey%
)else (
:: Program target MCU without complilation
if "%2" == "blast" (
	if exist "%~dpnx1.hex" "%~dp0%prognm%" -p "%part:~1%" -c %prog% -e %avrdvkeyw% %avrdakey% -U flash:w:"%~dpnx1.hex":i
	if not exist "%~dpnx1.hex" echo CMD engine : Warning - FLASH image "%~dpnx1.hex" not found!
	if exist "%~dpnx1.eeprom.hex" "%~dp0%prognm%" -p "%part:~1%" -c %prog% %avrdvkeyw% %avrdakey% -U eeprom:w:"%~dpnx1.eeprom.hex":i
	if not exist "%~dpnx1.eeprom.hex" echo CMD engine : Warning - EEPROM image "%~dpnx1.eeprom.hex" not found!
)else (
:: Run compilation without programming
if "%2" == "compile" (
	if exist "%~dpnx1.hex" del "%~dpnx1.hex"
	if exist "%~dpnx1.eeprom.hex" del "%~dpnx1.eeprom.hex"
	if exist "%~dpnx1.lst" del "%~dpnx1.lst"
	if "%usetavrasm%" == "true" (
	"%~dp0%tasmnm%" %tasmvkey% %tasmpkey% -i "%~dpnx1" -I "%~dp0include" -e "%~dpnx1.lst" -o "%~dpnx1.hex" -r "%~dpnx1.eeprom.hex"
	)else (
	"%~dp0%avrasmnm%" %aasmvkey% %aasmpkey% -fI -I "%~dp0include" -l "%~dpnx1.lst" -o "%~dpnx1.hex" -e "%~dpnx1.eeprom.hex" "%~dpnx1"
	)
)else (
:: Compile source and program target MCU
if "%2" == "prog" (
	if exist "%~dpnx1.hex" del "%~dpnx1.hex"
	if exist "%~dpnx1.eeprom.hex" del "%~dpnx1.eeprom.hex"
	if exist "%~dpnx1.lst" del "%~dpnx1.lst"
	if "%usetavrasm%" == "true" (
	"%~dp0%tasmnm%" %tasmvkey% %tasmpkey% -i "%~dpnx1" -I "%~dp0include" -o "%~dpnx1.hex" -r "%~dpnx1.eeprom.hex"
	)else (
	"%~dp0%avrasmnm%" %aasmvkey% %aasmpkey% -fI -I "%~dp0include" -o "%~dpnx1.hex" -e "%~dpnx1.eeprom.hex" "%~dpnx1"
	)
	if exist "%~dpnx1.hex" "%~dp0%prognm%" -p "%part:~1%" -c %prog% -e %avrdvkeyw% %avrdakey% -U flash:w:"%~dpnx1.hex":i
	if not exist "%~dpnx1.hex" echo CMD engine : Warning - FLASH image "%~dpnx1.hex" not found!
	if exist "%~dpnx1.eeprom.hex" "%~dp0%prognm%" -p "%part:~1%" -c %prog% %avrdvkeyw% %avrdakey% -U eeprom:w:"%~dpnx1.eeprom.hex":i
	if not exist "%~dpnx1.eeprom.hex" echo CMD engine : Warning - EEPROM image "%~dpnx1.eeprom.hex" not found!
	if exist "%~dpnx1.hex" del "%~dpnx1.hex"
	if exist "%~dpnx1.eeprom.hex" del "%~dpnx1.eeprom.hex"
)else (
:: Read target MCU and create files %1_dump.hex and %1_dump.eeprom.hex (dump)
if "%2" == "read" (
	"%~dp0%prognm%" -p "%part:~1%" -c %prog% %avrdvkeyr% %avrdakey% -U flash:r:"%~dpn1_dump%~x1.hex":i
	"%~dp0%prognm%" -p "%part:~1%" -c %prog% %avrdvkeyr% %avrdakey% -U eeprom:r:"%~dpn1_dump%~x1.eeprom.hex":i
)else (
:: Write dump files to MCU
if "%2" == "write" (
	if exist "%~dpn1_dump%~x1.hex" "%~dp0%prognm%" -p "%part:~1%" -c %prog% -e %avrdvkeyw% %avrdakey% -U flash:w:"%~dpn1_dump%~x1.hex":i
	if not exist "%~dpn1_dump%~x1.hex" echo CMD engine : Warning - FLASH image "%~dpn1_dump%~x1.hex" not found!
	if exist "%~dpn1_dump%~x1.eeprom.hex" "%~dp0%prognm%" -p "%part:~1%" -c %prog% %avrdvkeyw% %avrdakey% -U eeprom:w:"%~dpn1_dump%~x1.eeprom.hex":i
	if not exist "%~dpn1_dump%~x1.eeprom.hex" echo CMD engine : Warning - EEPROM image "%~dpn1_dump%~x1.eeprom.hex" not found!
)else (
:: Convert all existing hexadecimal "project" files to binary format (including dump)
if "%2" == "hbin" (
	if exist "%~dpnx1.hex" "%~dp0%hexbinnm%" -e bin "%~dpnx1.hex" && echo CMD engine : Bin file "%~dpnx1.bin" generated.
	if not exist "%~dpnx1.hex" echo CMD engine : Warning - FLASH image "%~dpnx1.hex" not found!
	if exist "%~dpnx1.hex" echo .
	if exist "%~dpnx1.eeprom.hex" "%~dp0%hexbinnm%" -e bin "%~dpnx1.eeprom.hex" && echo CMD engine : Bin file "%~dpnx1.eeprom.bin" generated.
	if not exist "%~dpnx1.eeprom.hex" echo CMD engine : Warning - EEPROM image "%~dpnx1.eeprom.hex" not found!
	if exist "%~dpnx1.eeprom.hex" echo .
	if exist "%~dpn1_dump%~x1.hex" "%~dp0%hexbinnm%" -e bin "%~dpn1_dump%~x1.hex" && echo CMD engine : Bin file "%~dpn1_dump%~x1.bin" generated.
	if not exist "%~dpn1_dump%~x1.hex" echo CMD engine : Info - FLASH image "%~dpn1_dump%~x1.hex" not found.
	if exist "%~dpn1_dump%~x1.hex" echo .
	if exist "%~dpn1_dump%~x1.eeprom.hex" "%~dp0%hexbinnm%" -e bin "%~dpn1_dump%~x1.eeprom.hex" && echo CMD engine : Bin file "%~dpn1_dump%~x1.eeprom.bin" generated.
	if not exist "%~dpn1_dump%~x1.eeprom.hex" echo CMD engine : Info - EEPROM image "%~dpn1_dump%~x1.eeprom.hex" not found.
)else (
:: Convert all existing binary "project" files to intel hex format (including dump)
if "%2" == "bhex" (
	if exist "%~dpnx1.bin" "%~dp0%binhexnm%" "%~dpnx1.bin" "%~dpnx1.hex" && echo CMD engine : Hex file "%~dpnx1.hex" generated.
	if not exist "%~dpnx1.bin" echo CMD engine : Warning - FLASH image "%~dpnx1.bin" not found!
	if exist "%~dpnx1.eeprom.bin" "%~dp0%binhexnm%" "%~dpnx1.eeprom.bin" "%~dpnx1.eeprom.hex" && echo CMD engine : Hex file "%~dpnx1.eeprom.hex" generated.
	if not exist "%~dpnx1.eeprom.bin" echo CMD engine : Warning - EEPROM image "%~dpnx1.eeprom.bin" not found!
	if exist "%~dpn1_dump%~x1.bin" "%~dp0%binhexnm%" "%~dpn1_dump%~x1.bin" "%~dpn1_dump%~x1.hex" && echo CMD engine : Hex file "%~dpn1_dump%~x1.hex" generated.
	if not exist "%~dpn1_dump%~x1.bin" echo CMD engine : Info - FLASH image "%~dpn1_dump%~x1.bin" not found!
	if exist "%~dpn1_dump%~x1.eeprom.bin" "%~dp0%binhexnm%" "%~dpn1_dump%~x1.eeprom.bin" "%~dpn1_dump%~x1.eeprom.hex" && echo CMD engine : Hex file "%~dpn1_dump%~x1.eeprom.hex" generated.
	if not exist "%~dpn1_dump%~x1.eeprom.bin" echo CMD engine : Info - EEPROM image "%~dpn1_dump%~x1.eeprom.bin" not found!
)else (
	echo CMD engine : Error: incorrect action.
)))))))))