@echo off

if [%1]==[] (
	echo Usage: .bat event
	goto EOF
)

set fileName=Notes_And_Bugs_In_Work.md

if not exist "%fileName%" (
	echo file %fileName% not exit 
	goto EOF
)

set d=%date:~0,10%
set t=%time:~0,8%
echo ^> %d% %t% %~1 >> %fileName%

echo Done. Add notes successfully

:EOF