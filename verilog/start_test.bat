@echo off

pushd scripts

call D:\School\Xilinx_ISE_DS_Win_14.7_1015_1\14.7\ISE_DS\settings64.bat
call clean.bat noref
call build.bat nodup
call run.bat nobuild nogui

popd

pause
