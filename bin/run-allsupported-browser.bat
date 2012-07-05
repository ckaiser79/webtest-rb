@echo off

rm -rf ../log/archived
mkdir ..\log\archived

ruby wetest-rb --verbose -b ie
mv ../log/last_run ../log/archived/log.ie

ruby wetest-rb --verbose -b firefox
mv ../log/last_run ../log/archived/log.firefox

ruby wetest-rb --verbose -b chrome
mv ../log/last_run ../log/archived/log.chrome

:end

