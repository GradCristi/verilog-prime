@echo off

if "%1%"=="noref" (
    del /F ..\scripts\..\build\fuse.xmsgs > NUL 2> NUL
    rmdir /S /Q ..\scripts\..\build\bin > NUL 2> NUL
    rmdir /S /Q ..\scripts\..\build\lib\tester > NUL 2> NUL
    rmdir /S /Q ..\scripts\..\build\lib\tests > NUL 2> NUL
    rmdir /S /Q ..\scripts\..\build\lib\uut > NUL 2> NUL
    rmdir /S /Q ..\scripts\..\build\lib\work > NUL 2> NUL
    rmdir /S /Q ..\scripts\..\build\synth > NUL 2> NUL
) else (
    rmdir /S /Q ..\scripts\..\build > NUL 2> NUL
)

rmdir /S /Q ..\scripts\..\run > NUL 2> NUL
