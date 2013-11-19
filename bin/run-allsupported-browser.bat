@echo off

ruby wetest-rb -b ie %*
mv ../log/last_run ../log/archived/log.ie

ruby wetest-rb -b ff %*
mv ../log/last_run ../log/archived/log.firefox

ruby wetest-rb -b chrome %*
mv ../log/last_run ../log/archived/log.chrome

:end

