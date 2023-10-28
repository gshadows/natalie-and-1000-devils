@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
pushd %~dp0

rem set ARC="C:\Program Files\7-Zip\7z.exe" a -tzip -mx=9
set ARC="C:\Program Files\7-Zip\7z.exe" a -t7z -mx=9 -myx=9

if not exist _export (
	echo No _export found!
	exit 1
)
if not exist _releases (
	mkdir _releases
	if not exist _releases (
		echo Can not create _releases!
		exit 2
	)
)
cd _export
rem del /F /Q libgitapi.dll

for %%c in (*.exe) do (
	set FNAME=%%c
	set ANAME=!FNAME:~0,-4!
	set NAME7Z=..\_releases\!FNAME:~0,-4!.7z
	set MASK=!FNAME:~0,-4!.*
	echo ===== Exporting !ANAME! =====
	%ARC% "!NAME7Z!" "!MASK!"
)

popd
echo ===== FINISHED =====
