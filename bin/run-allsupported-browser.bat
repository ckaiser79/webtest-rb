@echo off

rm -rf ../log/archived
mkdir ..\log\archived

ruby run_testcases --verbose -b ie
mv ../log/last_run ../log/archived/log.ie

ruby run_testcases --verbose -b firefox
mv ../log/last_run ../log/archived/log.firefox

ruby run_testcases --verbose -b chrome
mv ../log/last_run ../log/archived/log.chrome

:end

