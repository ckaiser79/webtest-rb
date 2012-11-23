@ECHO OFF

SET D=%1
IF "x%D%" == "x" SET D=log

SET F=../%D%/last_run/run.log
grep -n "\[FAIL\]" %F%
grep -n "WARN -- : Detected issue:" %F%
grep -n "\[SUCCESS\]" %F%
SET F=
