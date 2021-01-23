@echo off

SET run_mode=..\..\..\scripts\console.tcl

if "%2"=="gui" SET run_mode=..\..\..\scripts\gui.tcl -gui
if "%3"=="gui" SET run_mode=..\..\..\scripts\gui.tcl -gui

SET build_mode=call build_test.bat %1

if "%2"=="nobuild" SET build_mode=
if "%3"=="nobuild" SET build_mode=

%build_mode%

echo Running test %1...

rmdir /S /Q ..\scripts\..\run\%1 > NUL 2> NUL

mkdir ..\run\%1 2> NUL

mkdir ..\build\bin\%1 2> NUL
pushd ..\build\bin\%1

copy /Y ..\..\..\tests\%1\* . > NUL

echo ********************************************************************************> ..\..\..\run\%1\tester.log
echo **** Running test %1...>> ..\..\..\run\%1\tester.log
echo ********************************************************************************>> ..\..\..\run\%1\tester.log
tester.exe -intstyle ise -tclbatch %run_mode% >> ..\..\..\run\%1\tester.log

move /Y result.tester ..\..\..\run\%1\tester.result > NUL 2> NUL

popd