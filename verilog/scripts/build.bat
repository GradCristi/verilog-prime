@echo off

SET nodup=

if "%1"=="nodup" SET nodup=nodup

call build_base.bat %nodup%

for /D %%d in (..\tests\*) do (
    call build_test.bat %%~nd nobase
)
