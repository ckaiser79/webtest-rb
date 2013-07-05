@echo off

ruby wetest-rb --verbose -b ie -r -c
mv ../log/last_run ../log/archived/log.ie

ruby wetest-rb --verbose -b firefox -r -c
mv ../log/last_run ../log/archived/log.firefox

ruby wetest-rb --verbose -b chrome -r -c
mv ../log/last_run ../log/archived/log.chrome

:end

