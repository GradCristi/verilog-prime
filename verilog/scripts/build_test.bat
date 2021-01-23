@echo off

SET nodup=

if "%2"=="nodup" SET nodup=nodup
if "%3"=="nodup" SET nodup=nodup

SET build_mode=call build_base.bat %nodup%

if "%2"=="nobase" SET build_mode=
if "%3"=="nobase" SET build_mode=

%build_mode%

mkdir ..\build 2> NUL
pushd ..\build

if not exist lib\tests\%1 (
    echo Compiling test %1...
    for %%f in (..\tests\%1\*.v) do (
        vlogcomp -incremental -work test=lib\tests\%1 "%%f" > NUL
    )
)

popd

echo Linking test %1...

mkdir ..\build\bin\%1 2> NUL
pushd ..\build\bin\%1

fuse -incremental test.test_%1 -L unisims_ver -L unimacro_ver -L xilinxcorelib_ver -L tester=..\..\lib\tester -L test=..\..\lib\tests\%1 -L reference=..\..\lib\reference -L uut=..\..\lib\uut -o tester.exe > NUL

popd