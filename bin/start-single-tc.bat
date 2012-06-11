@echo off

SET TYPE=heise.de
SET TCID=%1

for /f "delims=" %%a in ('ls -1 ../testcases/%TYPE% ^| grep %TCID%') do @set TC=%%a 

:: some hacky trim function
set TC=%TC%##
set TC=%TC:                ##=##%
set TC=%TC:        ##=##%
set TC=%TC:    ##=##%
set TC=%TC:  ##=##%
set TC=%TC: ##=##%
set TC=%TC:##=%

ruby run_testcases --verbose -t "../testcases/%TYPE%/%TC%"

