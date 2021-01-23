@echo off

if not "%1"=="nodup" (
    call clean.bat
)

mkdir ..\build 2> NUL
pushd ..\build

if not exist lib\work (
    echo Compiling common files...
    vlogcomp %XILINX%\verilog\src\glbl.v -incremental -work work=lib\work > NUL
)

if not exist lib\tester (
    echo Compiling tester...
    for %%f in (..\tester\*.v) do (
        vlogcomp -incremental -work tester=lib\tester "%%f" > NUL
    )
)

if not exist lib\reference (
    echo Compiling reference implementation...
    for %%f in (..\reference\*.v) do (
        vlogcomp -incremental -work reference=lib\reference "%%f" > NUL
    )
)

mkdir synth 2> NUL

echo Compiling implementation under test...
for %%f in (..\src\*.v) do (
    vlogcomp -incremental -work uut=lib\uut "%%f" > NUL
    echo verilog work "..\%%f">> synth\tester.prj
)
echo verilog work "..\..\tester\ram.v.synth">> synth\tester.prj

pushd synth

echo Synthesizing implementation under test...
for %%f in (..\..\scripts\*.xst) do (
    xst -ifn "%%f" -intstyle silent
)

popd

popd
