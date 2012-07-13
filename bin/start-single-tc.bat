@echo off

IF "x%TCGROUP%" == "x" SET TCGROUP=samples
SET TCID=%1

IF "%TCID%" == "" GOTO USAGE

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

ruby webtest-rb %WT_OPTS% -t "../testcases/%TCGROUP%/%TC%"
GOTO END

:USAGE
echo start-single-tc.bat ^<testcase-spec^>
echo testcase-spec ... name of testcase in directory ../testcases/%TCGROUP%
echo                   may be a wildcard

:END
