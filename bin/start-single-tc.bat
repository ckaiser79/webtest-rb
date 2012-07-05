@echo off

IF "x%TCGROUP%" == "x" SET TCGROUP=samples
SET TCID=%1

for /f "delims=" %%a in ('ls -1 ../testcases/%TCGROUP% ^| grep %TCID%') do @set TC=%%a 

:: some hacky trim function
set TC=%TC%##
set TC=%TC:                ##=##%
set TC=%TC:        ##=##%
set TC=%TC:    ##=##%
set TC=%TC:  ##=##%
set TC=%TC: ##=##%
set TC=%TC:##=%

::set WT_OTPS=--verbose 
set WT_OPTS=

ruby wetest-rb %WT_OPTS% -t "../testcases/%TCGROUP%/%TC%"
